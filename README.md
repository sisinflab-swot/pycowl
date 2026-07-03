# PyCowl

*PyCowl* is a Python library for working with OWL 2 ontologies, developed by
[SisInf Lab][swot] at the [Polytechnic University of Bari][poliba].

### Installation

PyCowl is available [via PyPI][pypi], with pre-built wheels for common platforms and
architectures. Installing it is as easy as:

```bash
pip install pycowl
```

If there are no wheels for your platform, a source distribution build is attempted,
in which case you will also need to satisfy the build dependencies of the underlying
[Cowl][cowl] library (refer to the build requirements section of its docs).

### API documentation

Refer to the [examples][examples] to get started. The library's [stub file][stub]
has docstrings and uses type annotations extensively, so the autocomplete feature
of IDEs/editors will likely provide most of the needed guidance. Structured HTML
docs are currently being worked on.

### CLI usage

PyCowl can also be used as a CLI tool:

- `pycowl convert`: converts ontologies between supported formats.
- `pycowl diff`: shows changes between ontologies.
- `pycowl stats`: displays basic statistics about ontologies.

### Acknowledgements

Work supported by the [Space It Up!][siu] project, funded by the [Italian Space Agency (ASI)][asi]
and the [Ministry of University and Research (MUR)][mur],
under contract n. 2024-5-E.0 - CUP n. I53D24000060005.

### Copyright and License

Copyright © 2026 [SisInf Lab][swot], [Polytechnic University of Bari][poliba]

PyCowl is distributed under the [Eclipse Public License, Version 2.0][epl2].

[asi]: https://www.asi.it
[cowl]: https://swot.sisinflab.poliba.it/cowl
[epl2]: https://www.eclipse.org/legal/epl-2.0
[mur]: https://www.mur.gov.it
[examples]: https://github.com/sisinflab-swot/pycowl/blob/stable/examples
[poliba]: http://www.poliba.it
[pypi]: https://pypi.org/project/pycowl
[siu]: https://spaceitup.it
[stub]: https://github.com/sisinflab-swot/pycowl/blob/stable/src/cowl/_cowl.pyi
[swot]: http://swot.sisinflab.poliba.it
