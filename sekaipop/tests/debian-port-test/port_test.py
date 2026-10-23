#!/usr/bin/env python3
"""Behavior tests for runtime gates, APT parsing and suspend acknowledgement."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]

class PortTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.work = Path(self.tmp.name)
        self.bin = self.work / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, PATH=str(self.bin)+':'+os.environ['PATH'])

    def command(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/sh\n'+body+'\n')
        path.chmod(0o755)
        return path

    def run_script(self, relative, *args):
        return subprocess.run(['bash', str(ROOT / relative), *map(str,args)],
                              env=self.env, text=True, capture_output=True)

    def test_suspend_requires_compositor_confirmation(self):
        marker = self.work / 'suspended'
        self.command('systemctl', f'touch "{marker}"')
        self.command('qs', 'case "$*" in *secure) echo false;; esac')
        self.command('sleep', 'exit 0')
        result = self.run_script('scripts/system/secure-suspend.sh')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(marker.exists())
        self.command('qs', 'case "$*" in *secure) echo true;; esac')
        result = self.run_script('scripts/system/secure-suspend.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(marker.exists())

    def test_failed_lock_never_suspends(self):
        self.command('qs', 'exit 1')
        self.command('systemctl', 'exit 99')
        result = self.run_script('scripts/system/secure-suspend.sh')
        self.assertEqual(result.returncode, 1)
        self.assertIn('refusing suspend', result.stderr)

    @unittest.skipUnless(Path('/etc/debian_version').exists(), 'Debian backend test')
    def test_apt_query_is_read_only_and_parses_versions(self):
        self.command('apt-get', 'printf "Inst demo [1.0] (2.0 Debian:13 [arm64])\\n"')
        self.command('apt-mark', 'echo held-package')
        self.command('sudo', 'echo UNEXPECTED_SUDO; exit 99')
        result = self.run_script('scripts/system/pkg-updates.sh', 'check', '1')
        self.assertEqual(result.returncode, 0, result.stderr)
        for line in ['backend=apt', 'status=ok', 'repo=1', 'aur=0', 'held=1', 'pkg=demo 1.0 -> 2.0']:
            self.assertIn(line, result.stdout)
        self.assertNotIn('UNEXPECTED_SUDO', result.stdout)
        self.command('apt-get', 'exit 100')
        self.assertIn('status=error', self.run_script('scripts/system/pkg-updates.sh','check').stdout)

    @unittest.skipUnless(Path('/etc/debian_version').exists(), 'Debian install gate')
    def test_failed_shader_keeps_previous_install(self):
        config = self.work / 'config'
        installed = config / 'quickshell/sekaipop'
        installed.mkdir(parents=True)
        (installed / 'sentinel').write_text('old desktop')
        self.env['XDG_CONFIG_HOME'] = str(config)
        self.env['QSB'] = str(self.command('qsb', 'case "$1" in --version) echo "qsb 6.8.2";; *) exit 1;; esac'))
        result = subprocess.run(['bash', str(ROOT.parent/'install.sh'), '--yes', '--no-deps', '--hypr', 'skip'],
                                env=self.env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('compiling', result.stdout)
        self.assertEqual((installed/'sentinel').read_text(), 'old desktop')
        self.assertFalse(list(installed.parent.glob('.sekaipop-stage.*')))

    def test_managed_update_rejects_failed_runtime(self):
        repo = self.work/'remote'
        repo.mkdir()
        env = dict(self.env, GIT_AUTHOR_NAME='test', GIT_AUTHOR_EMAIL='test@example.invalid',
                   GIT_COMMITTER_NAME='test', GIT_COMMITTER_EMAIL='test@example.invalid')
        def git(*args):
            return subprocess.check_output(['git','-C',str(repo),*args],env=env,text=True).strip()
        git('init','-q','-b','main')
        rice = repo/'sekaipop'
        scripts = rice/'scripts/system'
        scripts.mkdir(parents=True)
        shutil.copy(ROOT/'scripts/system/update-check.sh',scripts/'update-check.sh')
        (scripts/'prepare-runtime.sh').write_text('exit 0\n')
        (scripts/'check-qml.sh').write_text('exit 0\n')
        (rice/'shell.qml').write_text('import QtQuick\n')
        (rice/'VERSION').write_text('1.0.0\n')
        git('add','.')
        git('commit','-qm','initial')
        old = git('rev-parse','HEAD')
        installed = self.work/'installed'
        shutil.copytree(rice,installed)
        (installed/'.source').write_text(f'commit={old}\nrepo={repo}\nref=main\nmanaged=yes\n')
        (rice/'VERSION').write_text('1.0.1\n')
        (scripts/'prepare-runtime.sh').write_text('echo incompatible >&2; exit 1\n')
        git('add','.')
        git('commit','-qm','bad runtime')
        result=subprocess.run(['sh',str(installed/'scripts/system/update-check.sh'),'apply'],env=env,capture_output=True,text=True)
        self.assertNotEqual(result.returncode,0)
        self.assertEqual((installed/'VERSION').read_text(),'1.0.0\n')
        self.assertFalse(Path(str(installed)+'.update-new').exists())
        (scripts/'prepare-runtime.sh').write_text('exit 0\n')
        git('add','.')
        git('commit','-qm','compatible runtime')
        result=subprocess.run(['sh',str(installed/'scripts/system/update-check.sh'),'apply'],env=env,capture_output=True,text=True)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertEqual((installed/'VERSION').read_text(),'1.0.1\n')
        self.assertEqual((Path(str(installed)+'.previous')/'VERSION').read_text(),'1.0.0\n')

    def test_incompatible_binary_shader_is_rejected(self):
        rice = self.work / 'rice'
        shutil.copytree(ROOT / 'shaders', rice / 'shaders')
        qsb = self.command('qsb', '''case "$1" in
--version) echo 'qsb 6.8.2';;
--dump) case "$2" in *visualizer*) exit 1;; *) echo 'SPIR-V GLSL';; esac;;
*) exit 0;;
esac''')
        self.command('dpkg-query', 'exit 1')
        self.env['QSB'] = str(qsb)
        result = self.run_script('scripts/system/prepare-runtime.sh', rice)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Incompatible shader', result.stderr)
        self.assertFalse((rice / '.runtime').exists())

if __name__ == '__main__':
    unittest.main()
