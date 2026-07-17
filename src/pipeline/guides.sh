write_guides() {
echo "[8/12] Creating Notion-oriented evidence guides..."

# Create the evidence guide.
cat > "$SUMMARY_DIR/01_notion_evidence_guide.md" <<'EOF'
# Notion Evidence Guide

## 📚 About the Project

Review repository information, folder structure, scenes, prefabs, package
manifests, current project metrics, README files, and Unity settings.

Describe the product, audience, goals, platforms, scope, and production context.
Do not infer the complete product purpose from file names alone.

## 🎯 My Mission

Review the contribution summary, complete commit history, system-related commit
subjects, top changed files, and top changed directories.

Combine Git evidence with personal context about responsibilities and ownership.

## 🏗 Major Systems I Contributed To

Review likely system files, architecture signals, networking signals, service
signals, top changed files, top changed directories, and exported source code.

Distinguish systems that merely exist from systems changed in the selected
history scope.

## ⚙ Engineering Contributions

Review architecture signals, performance signals, editor tooling, technical-debt
markers, large scripts, commit history, and source code.

Look for implementation, refactoring, optimization, debugging, tooling,
persistence, integration, platform, release, and production-stability work.

## 🧠 Technologies

Review package manifests, Unity version, assemblies, shaders, UI Toolkit,
Timeline, Addressables, networking, services, databases, editor tooling, and
project settings.

## 🤝 Collaboration

Review contributor lists, merge history, commit history, branches, and known
multidisciplinary team context.

Git can show integration activity, but it cannot fully prove meetings, design
collaboration, mentoring, or stakeholder relationships.

## 🌱 What I Learned

Use project complexity, newly adopted technologies, recurring problems,
refactors, and increasing ownership as evidence.

This section requires personal confirmation and should not be generated from
metrics alone.

## 🚀 Biggest Engineering Achievements

Prefer achievements combining technical difficulty, scope, ownership, reuse,
player or product impact, reliability, performance, and maintainability.

Do not use raw file-touch numbers as achievements without context.

## ⭐ Personal Reflection

Use the evidence to support a personal reflection about growth, values,
decisions, trade-offs, and how the project shaped professional identity.

This section must remain personal rather than sounding like marketing copy.
EOF

# Create a reusable analysis prompt.
cat > "$SUMMARY_DIR/02_analysis_prompt.md" <<'EOF'
# Analysis Request

Analyze this project export and Git history carefully.

Separate:

1. Current project-wide facts
2. Historical contribution signals for the selected history scope
3. Third-party or generated content
4. Evidence-supported conclusions
5. Inferences that must be labeled as inferences
6. Personal reflections that require contributor confirmation

Create a detailed Notion document with:

- 📚 About the Project
- 🎯 My Mission
- 🏗 Major Systems I Contributed To
- ⚙ Engineering Contributions
- 🧠 Technologies
- 🤝 Collaboration
- 🌱 What I Learned
- 🚀 Biggest Engineering Achievements
- ⭐ Personal Reflection

Rules:

- Do not equate files touched with files authored.
- Do not claim imported packages as original work.
- Distinguish current metrics from historical Git change volume.
- Use source code, commits, folders, packages, and settings together.
- Explain uncertainty.
- Prefer concrete systems, decisions, and impact over generic claims.
- Treat the document as personal career journaling.
EOF

# Print the ninth progress step.
}
