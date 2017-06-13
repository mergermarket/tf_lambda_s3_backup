import os
import re
import shutil
import tempfile
import unittest
from subprocess import check_call, check_output


class TestCreateTaskdef(unittest.TestCase):

    def setUp(self):
        self.workdir = tempfile.mkdtemp()
        self.module_path = os.path.join(os.getcwd(), 'test', 'infra')

        check_call(
            ['terraform', 'get', self.module_path],
            cwd=self.workdir)

    def tearDown(self):
        if os.path.isdir(self.workdir):
            shutil.rmtree(self.workdir)

    def test_runs_plan(self):
        output = check_output([
            'terraform',
            'plan',
            '-no-color',
            self.module_path],
            cwd=self.workdir
        ).decode('utf-8')
        assert output
