# ATS-friendly résumé design and the X-Y-Z formula

## Research summary

The X-Y-Z formula is commonly attributed to Google's recruiting guidance:
"Accomplished X, as measured by Y, by doing Z." Its useful constraint is not the
word order; it is the requirement that a résumé claim identify an outcome, a
measurement, and the action that produced it. RepoDNA must never manufacture Y
from commit counts or line changes. Those are repository metrics, not proof of
personal or product impact.

Google's current career guidance likewise recommends showing how skills translate
to a target role, integrating job-description keywords organically, and supporting
claims with specific details and measurable results. The U.S. Department of Labor
advises ATS-oriented applicants to use relevant keywords and avoid layouts such as
tables or columns that parsers may not read reliably.

Sources:

- [Grow with Google: career and résumé guidance](https://grow.google/grow-your-career/articles/career-change/)
- [Grow with Google: measurable results in career narratives](https://grow.google/certificates/interview-warmup/)
- [U.S. Department of Labor: Resume Essentials](https://www.dol.gov/sites/dolgov/files/VETS/files/ResumeEssentials_PG_Interactive_Feb2026.pdf)
- [X-Y-Z formula overview and attribution](https://www.tealhq.com/post/xyz-resume)

## Proposed data contract

An eventual `career/resume-evidence.json` should consume confirmed Notion evidence,
not raw repository metrics directly:

```json
{
  "target_role": null,
  "job_description_keywords": [],
  "achievements": [
    {
      "x_outcome": null,
      "y_measurement": null,
      "z_action": null,
      "evidence": [],
      "confidence": "low",
      "personal_confirmation_required": true
    }
  ]
}
```

Generation must require X and Z. Y may be absent when no honest measurement
exists, in which case the output should remain a contribution statement rather
than inventing a quantified achievement. Job-description keywords must be used
only when supported by confirmed experience.

## ATS renderer constraints

- Use a single column and conventional section headings.
- Keep contact details as text, outside headers, footers, images, or text boxes.
- Produce semantic DOCX and a simple text-based PDF from the same confirmed data.
- Avoid charts, icons, skill bars, and decorative tables.
- Preserve exact supported terminology from the target job description without
  keyword stuffing.
- Keep dates, employer names, job titles, skills, and achievements machine-readable.
- Include provenance internally, but omit evidence paths from the submitted résumé.
