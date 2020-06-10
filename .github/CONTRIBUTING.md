# Contributing to pyxpdf

Bug fixes, feature additions, tests, documentation and more can be contributed via [issues](https://github.com/ashutoshvarma/pyxpdf/issues) and/or [pull requests]((https://github.com/ashutoshvarma/pyxpdf/pulls). All contributions are welcome.

## Bug fixes, feature additions, etc.

Please send a pull request to the master branch. Please include [documentation](https://pyxpdf.readthedocs.io) and tests for new features. Tests or documentation without bug fixes or feature additions are welcome too. Feel free to ask questions [via issues](https://github.com/ashutoshvarma/pyxpdf/issues).

- Fork the pyxpdf repository.
- Create a branch from master.
- Develop bug fixes, features, tests, etc.
- Run the test suite (see [Build](https://github.com/ashutoshvarma/pyxpdf/blob/master/BUILD.rst)). You can enable [Travis CI](https://travis-ci.org/profile/) and [Azure Pipelines](https://github.com/marketplace/azure-pipelines) on your repo to catch test failures prior to the pull request, and [Codecov](https://codecov.io/gh) to see if the changed code is covered by tests.
- Create a pull request to pull the changes from your branch to the pyxpdf master.

### Guidelines

- Separate code commits from reformatting commits.
- Provide tests for any newly added code.
- When committing only documentation changes please include [skip ci] in the commit message to avoid running tests on Travis-CI and Azure Pipelines.

## Reporting Issues

When reporting issues, please include code that reproduces the issue and whenever possible, a pdf that demonstrates the issue. Please upload pdf to GitHub, not to third-party file hosting sites. If necessary, add the pdf to a zip or tar archive.

The best reproductions are self-contained scripts with minimal dependencies. If you are using a framework such as plone, Django, or buildout, try to replicate the issue just using pyxpdf.

### Provide details

- What did you do?
- What did you expect to happen?
- What actually happened?
- What optional dependencies of pyxpdf are you using?
- What versions of pyxpdf and Python are you using?
