# CLAUDE.md — TrustGym PFE Report

Rapport de Projet de Fin d'Études (PFE) rédigé en LaTeX pour la plateforme TrustGym.
Auteur : Okba Bedhiafi — 5TWIN, ESPRIT, 2025-2026. Entreprise : TRUSTLINK.

---

## Structure du projet

```
TrustGym_PFE_Report/
├── main.tex                    ← Fichier principal (packages, acronymes, \subfile)
├── references.bib              ← Bibliographie BibLaTeX (biber)
├── chapters/
│   ├── 0 Cadre General.tex     ← Chapitre 1 : Contexte, entreprise, concurrents
│   ├── 1 Approche.tex          ← Chapitre 2 : Scrum, technologies, architecture
│   ├── 2 Exigences.tex         ← Chapitre 3 : Acteurs, UC global, backlog, classe
│   ├── 3 Sprint 1.tex          ← Chapitre 4 : Auth & utilisateurs
│   ├── 4 Sprint 2.tex          ← Chapitre 5 : Membres & abonnements
│   ├── 5 Sprint 3.tex          ← Chapitre 6 : Accès & matériel
│   ├── 6 Sprint 4.tex          ← Chapitre 7 : Coachs & séances
│   ├── 7 Sprint 5.tex          ← Chapitre 8 : Boutique & stock
│   ├── 8 Sprint 6.tex          ← Chapitre 9 : Finance & facturation
│   └── 9 Sprint 7.tex          ← Chapitre 10 : Mobile, KPI, IA/RAG
├── sections/
│   ├── Remerciements.tex
│   ├── Introduction Generale.tex
│   └── Conclusion Generale.tex
├── img/                        ← Images générales (logos, diagrammes, captures)
│   ├── agile logo.png
│   ├── class diagram.png
│   ├── glofox logo.png
│   ├── gymmaster logo.png
│   ├── Logo_ESPRIT.png
│   ├── Technologie utilisee.png
│   ├── trust_link_logo.jpg
│   └── trustgym-logo.png
├── architectures images/       ← Schémas d'architecture (LOGIQUE, PHYSIQUE, etc.)
│   ├── ARCHITECTURE LOGIQUE.png
│   ├── ARCHITECTURE PHYSIQUE.png
│   ├── ARCHITECTURE CICD.png
│   ├── ARCHITECTURE MACHINES.png
│   └── RAG ARCHITECTURE.png
└── pdf/                        ← Couvertures PDF
    ├── front_cover.pdf
    ├── signature_cover.pdf
    └── back_cover.pdf
```

---

## Compilation

Toujours dans cet ordre exact :

```cmd
cd "C:\Users\BEDHIAFI\Desktop\Projects\TRUSTGYM\PFE REPORT\TrustGym_PFE_Report"
pdflatex main.tex
biber main
makeglossaries-lite main
pdflatex main.tex
pdflatex main.tex
```

> `makeglossaries-lite` est utilisé à la place de `makeglossaries` (pas de Perl installé).

---

## Packages LaTeX principaux

| Package | Rôle |
|---------|------|
| `biblatex` + `biber` | Bibliographie (style numeric) |
| `glossaries [acronym, toc, nonumberlist, nopostdot]` | Page des acronymes |
| `subfiles` | Un fichier par chapitre, compilable séparément |
| `tikz` | Diagrammes UML (use case, séquence) dessinés en code |
| `graphicx` | Inclusion d'images |
| `pdfpages` | Inclusion des couvertures PDF |
| `hyperref` | Liens cliquables dans le PDF |
| `babel [french]` | Typographie française |

---

## Conventions TikZ — Diagrammes de cas d'utilisation

**Règle absolue** : acteurs toujours à **gauche** (x négatif ≈ -2.5), boîte système à **droite** (x positif ≈ 5).

```latex
% Acteur (gauche)
\stickfigure{(-2.5, 0)}{NomActeur}
\draw (-1, 0) -- (ucN.west);

% Boîte système (droite)
\node[systembox] at (5, 0) {...};

% Use case (dans la boîte)
\node[usecase] (ucN) at (5, 0) {Nom UC};
```

---

## Acronymes définis (main.tex)

Tous les acronymes sont définis dans `main.tex` avec `\newacronym{}{}{}`.
Usage dans le texte : `\acrshort{api}`, `\acrfull{saas}`, etc.

Acronymes existants : api, jwt, orm, cicd, ssr, css, html, js, ts, sql, ide, ui, ux,
rest, crud, dto, sdk, qr, rag, ai, kpi, rbac, saas, json, pdf, lts, mvp, b2b, otp,
smtp, ws, cdn, vps, rfid, http, https, tcp, aws, mvc, url, uuid, tls, npm, nat, rtl,
nfc, cors, ssh, eas, erp

---

## Technologies du projet TrustGym

- **Backend** : NestJS 10, TypeORM, PostgreSQL 16 + pgvector, Passport.js JWT
- **Web** : Next.js 15, TanStack Query, Tailwind CSS, NextAuth.js, Yup, next-intl
- **Mobile** : React Native, Expo SDK 54, NativeWind
- **Temps réel** : Socket.IO `/attendance` + PostgreSQL LISTEN/NOTIFY
- **IA/RAG** : OpenAI `text-embedding-3-small` + `gpt-4o-mini` + pgvector
- **Matériel** : ZKTeco SDK (TCP 4370), Hikvision ISAPI (HTTPS)
- **Infra** : VPS OVH, PM2, Nginx, Vercel, GitHub Actions CI/CD, AWS S3

**NE PAS mentionner** : Docker, Zod (non utilisés dans le projet)

---

## Concurrents analysés (Chapitre 0)

- **Glofox** : plateforme irlandaise — `img/glofox logo.png` — `\cite{glofox}`
- **GymMaster** : logiciel néo-zélandais — `img/gymmaster logo.png` — `\cite{gymmaster}`

---

## Captures d'écran à fournir

Les chapitres 3–9 contiennent des `\fbox{\parbox{...}}` comme placeholders.
Remplacer par `\includegraphics[width=\textwidth]{nom-image.png}` une fois les PNG disponibles.
