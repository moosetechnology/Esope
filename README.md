# Esope

To load this project:
```St
Metacello new
  baseline: 'Esope';
  repository: 'github://moosetechnology/Esope';
	onConflict: [ :ex | ex allow ];
  load.
```

# Esope migration infrastructure


The entire Esope to Fortran-2008 migration project can be loaded from this repository: [https://github.com/moosetechnology/FAST-Fortran-2K](https://github.com/moosetechnology/FAST-Fortran-2K).
Ce code fonctionne pour la version Moose-13.

- **Parsing Fortran-77 with proprietary extensions**
  Younoussa Sow, Larisa Safina, Léandre Brault, Papa Ibou Diouf, Stéphane Ducasse, Nicolas Anquetil
  *IEEE International Conference on Software Maintenance and Evolution (ICSME)*, 2023
  DOI: 10.48550/arXiv.2309.02019
- **Migrating Esope to Fortran 2008 using model transformations**
  Younoussa Sow, Nicolas Anquetil, Léandre Brault, Stéphane Ducasse
  *IEEE International Conference on Software Analysis, Evolution, and Reengineering (SANER)*, 2026
  DOI: 10.48550/arXiv.2601.21755
