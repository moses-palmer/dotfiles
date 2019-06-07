import os
import unittest

from typing import Dict

from dotfiles.features import configuration


def name(s: str) -> str:
    """Generates the name of a file in this directory.

    :param s: The file name, relative to this directory.

    :return: a file name that may not necessarily exist
    """
    return os.path.join(os.path.dirname(__file__), s)


class ConfigurationTest(unittest.TestCase):
    def test_load_nonexisting(self):
        self.assertEqual(
            {
                'DEFAULT': {},
            },
            norm(configuration.Configuration(
                name('__invalid__'))))

    def test_load_simple(self):
        self.assertEqual(
            {
                'DEFAULT': {},
                'section1': {
                    'key1': 'value1',
                },
            },
            norm(configuration.Configuration(
                name('simple.conf'))))

    def test_load_with_predicates(self):
        self.assertEqual(
            {
                'DEFAULT': {},
                'section1': {
                    'key1': 'value1',
                },
                'section3': {
                    'key1': 'value1',
                },
            },
            norm(configuration.Configuration(
                name('with-predicates.conf'),
                include=True,
                exclude=False,
                keep=lambda s: s == 'sec3',
                sec='sec3')))

    def test_load_with_predicates_accumulating(self):
        self.assertEqual(
            {
                'DEFAULT': {},
                'section1': {
                    'key1': 'value1',
                    'keyx': 'valuex',
                },
                'section3': {
                    'key1': 'value1',
                    'keyy': 'valuey',
                },
            },
            norm(configuration.Configuration(
                name('with-predicates-accumulating.conf'),
                include=True,
                exclude=False,
                keep=lambda s: s == 'sec3',
                sec='sec3')))

    def test_load_reserved_section(self):
        with self.assertRaises(ValueError):
            configuration.Configuration(
                name('with-reserved-section.conf'),
                include=True,
                exclude=False,
                keep=lambda s: s == 'sec3',
                sec='sec3')


def norm(c):
    c= dict(c)
    del c[configuration.Configuration.ENV_SECTION]
    return c
