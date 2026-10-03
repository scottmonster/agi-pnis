#!/usr/bin/env node

import { existsSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';

const formatDirectory = new URL('.', import.meta.url).pathname;
const catalogPath = join(formatDirectory, 'list_complete.md');
const sourcesPath = join(formatDirectory, 'sources.md');
const indexPath = join(formatDirectory, 'index.html');
const examplesDirectory = join(formatDirectory, 'examples');

const command = process.argv[2];

if (!['migrate', 'index', 'check'].includes(command)) {
  fail('Usage: node docs/concepts/format/catalog-tools.mjs <migrate|index|check>');
}

function fail(message) {
  process.stderr.write(`${message}\n`);
  process.exit(1);
}

function read(path) {
  return readFileSync(path, 'utf8');
}

function write(path, content) {
  writeFileSync(path, content.endsWith('\n') ? content : `${content}\n`);
}

function trimPeriod(value) {
  return value.trim().replace(/\.$/, '');
}

function displayClassification(value) {
  return `${value.charAt(0).toUpperCase()}${value.slice(1)}`;
}

function html(value) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function markdownLinkCount(value) {
  return [...value.matchAll(/\[[^\]]+\]\(https?:\/\/[^)]+\)/g)].length;
}

function normalizedTerm(value) {
  return value.trim().toLocaleLowerCase();
}

function aliasTerms(value) {
  return value.split(/[;,]/).map((term) => term.trim()).filter(Boolean);
}

function parseLegacyCatalog(content) {
  const records = [];
  const output = ['# Code Design Concept Catalog', ''];
  const sources = [
    '# Code Design Concept Sources',
    '',
    'This ledger preserves the direct research sources for the canonical [code design concept catalog](list_complete.md).',
    '',
  ];
  let section = null;
  let subsection = null;
  let position = 0;

  for (const line of content.split(/\r?\n/)) {
    const sectionMatch = line.match(/^## (\d+)\. (.+)$/);
    if (sectionMatch) {
      section = { number: sectionMatch[1], title: sectionMatch[2] };
      subsection = null;
      output.push('', line);
      sources.push(`## ${section.number}. ${section.title}`, '');
      continue;
    }

    const subsectionMatch = line.match(/^### (\d+)\.(\d+) (.+)$/);
    if (subsectionMatch) {
      if (!section) fail(`Subsection without section: ${line}`);
      subsection = {
        number: `${subsectionMatch[1]}.${subsectionMatch[2]}`,
        title: subsectionMatch[3],
      };
      position = 0;
      output.push('', line);
      sources.push(`### ${subsection.number} ${subsection.title}`, '');
      continue;
    }

    if (!line.startsWith('1. **') && !/^\d+\. \*\*/.test(line)) continue;
    if (!section || !subsection) fail(`Concept without category: ${line}`);

    position += 1;
    const identifier = `${subsection.number}.${position}`;
    const record = parseLegacyEntry(line, identifier, section, subsection);
    records.push(record);
    output.push('', formatCatalogEntry(record));
    sources.push(`#### ${record.identifier} ${record.name}`, '', `- ${record.sources}`, '');
  }

  if (records.length === 0) fail('No legacy catalog records found.');
  return { catalog: `${output.join('\n')}\n`, records, sources: `${sources.join('\n').trimEnd()}\n` };
}

function parseLegacyEntry(line, identifier, section, subsection) {
  const start = line.match(/^\d+\. \*\*(.+?)\*\*\. (.+)$/);
  if (!start) fail(`Cannot parse concept entry: ${line}`);

  const name = start[1];
  let remainder = start[2];
  let aliases = '';
  const aliasMatch = remainder.match(/^Alias(?:es)?: (.+?)\. \*\*Classification:\*\* (.+)$/);
  if (aliasMatch) {
    aliases = aliasMatch[1];
    remainder = `**Classification:** ${aliasMatch[2]}`;
  }

  const classificationMatch = remainder.match(/^\*\*Classification:\*\* ([^.]+)\. (.+)$/);
  if (!classificationMatch) fail(`Cannot parse classification for ${name}.`);
  const classification = classificationMatch[1];
  const detail = classificationMatch[2];

  const sourceMarker = detail.indexOf(' Source: ') >= 0
    ? ' Source: '
    : detail.indexOf(' Sources: ') >= 0
      ? ' Sources: '
      : null;
  if (!sourceMarker) fail(`Missing source for ${name}.`);

  const sourceAt = detail.indexOf(sourceMarker);
  const definition = detail.slice(0, sourceAt).trim();
  let tail = detail.slice(sourceAt + sourceMarker.length).trim();
  let related = '';
  let distinction = '';
  const relatedAt = tail.indexOf('. Related: ');
  const distinctionAt = tail.indexOf('. Distinction: ');
  const splitAt = [relatedAt, distinctionAt].filter((index) => index >= 0).sort((a, b) => a - b)[0];
  const sourceText = trimPeriod(splitAt === undefined ? tail : tail.slice(0, splitAt));
  tail = splitAt === undefined ? '' : tail.slice(splitAt + 2);

  if (tail.startsWith('Related: ')) {
    const relatedText = tail.slice('Related: '.length);
    const nextDistinction = relatedText.indexOf('. Distinction: ');
    related = trimPeriod(nextDistinction >= 0 ? relatedText.slice(0, nextDistinction) : relatedText);
    if (nextDistinction >= 0) distinction = trimPeriod(relatedText.slice(nextDistinction + '. Distinction: '.length));
  } else if (tail.startsWith('Distinction: ')) {
    distinction = trimPeriod(tail.slice('Distinction: '.length));
  }

  if (markdownLinkCount(sourceText) === 0) fail(`Missing direct source URL for ${name}.`);

  return {
    identifier,
    name,
    aliases,
    classification,
    definition,
    related,
    distinction,
    sources: sourceText,
    section,
    subsection,
  };
}

function formatCatalogEntry(record) {
  const metadata = [displayClassification(record.classification)];
  if (record.aliases) metadata.push(`also known as: ${record.aliases}`);
  const related = record.related ? ` _Related:_ ${record.related}.` : '';
  const distinction = record.distinction ? ` _Distinction:_ ${record.distinction}.` : '';
  return `${record.identifier} **${record.name}** _(${metadata.join('; ')})_ - ${record.definition}${related}${distinction}`;
}

function parseCanonicalCatalog(content) {
  const records = [];
  let section = null;
  let subsection = null;

  for (const line of content.split(/\r?\n/)) {
    const sectionMatch = line.match(/^## (\d+)\. (.+)$/);
    if (sectionMatch) {
      section = { number: sectionMatch[1], title: sectionMatch[2] };
      subsection = null;
      continue;
    }
    const subsectionMatch = line.match(/^### (\d+\.\d+) (.+)$/);
    if (subsectionMatch) {
      subsection = { number: subsectionMatch[1], title: subsectionMatch[2] };
      continue;
    }
    const match = line.match(/^(\d+\.\d+\.\d+) \*\*(.+?)\*\* _\((.+?)\)_ - (.+)$/);
    if (!match) continue;
    if (!section || !subsection) fail(`Canonical concept without category: ${line}`);
    const [, identifier, name, metadata, detail] = match;
    const [classification, ...aliasParts] = metadata.split('; also known as: ');
    let definition = detail;
    let related = '';
    let distinction = '';
    const relatedAt = definition.indexOf(' _Related:_ ');
    const distinctionAt = definition.indexOf(' _Distinction:_ ');
    const splitAt = [relatedAt, distinctionAt].filter((index) => index >= 0).sort((a, b) => a - b)[0];
    const detailHead = splitAt === undefined ? definition : definition.slice(0, splitAt);
    let suffix = splitAt === undefined ? '' : definition.slice(splitAt + 1);
    definition = detailHead.trim();
    if (suffix.startsWith('_Related:_ ')) {
      suffix = suffix.slice('_Related:_ '.length);
      const nextDistinction = suffix.indexOf(' _Distinction:_ ');
      related = trimPeriod(nextDistinction >= 0 ? suffix.slice(0, nextDistinction) : suffix);
      if (nextDistinction >= 0) distinction = trimPeriod(suffix.slice(nextDistinction + ' _Distinction:_ '.length));
    } else if (suffix.startsWith('_Distinction:_ ')) {
      distinction = trimPeriod(suffix.slice('_Distinction:_ '.length));
    }
    records.push({
      identifier,
      name,
      aliases: aliasParts.join('; also known as: '),
      classification: classification.toLowerCase(),
      definition,
      related,
      distinction,
      section,
      subsection,
    });
  }

  if (records.length === 0) fail('No canonical catalog records found.');
  return records;
}

function renderIndex(records) {
  const rows = [...records]
    .sort((left, right) => left.name.localeCompare(right.name))
    .map((record) => {
      const category = `${record.section.number}. ${record.section.title} / ${record.subsection.number} ${record.subsection.title}`;
      const search = [record.identifier, record.name, record.classification, category, record.aliases].join(' ').toLowerCase();
      return `<tr data-search="${html(search)}"><td>${html(record.identifier)}</td><td>${html(record.name)}</td><td>${html(displayClassification(record.classification))}</td><td>${html(category)}</td><td>${html(record.aliases || '—')}</td></tr>`;
    })
    .join('\n');

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Code Design Concept Index</title>
  <style>
    body { font-family: system-ui, sans-serif; line-height: 1.5; margin: 2rem auto; max-width: 96rem; padding: 0 1rem; }
    input { font: inherit; margin: 0.5rem 0 1rem; padding: 0.5rem; width: min(100%, 42rem); }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #bbb; padding: 0.5rem; text-align: left; vertical-align: top; }
    th { background: #f3f3f3; }
    [hidden] { display: none; }
  </style>
</head>
<body>
  <main>
    <h1>Code Design Concept Index</h1>
    <p>This alphabetical index is derived from <a href="list_complete.md">the canonical catalog</a>. Search by catalog identifier, canonical name, classification, category, or alias.</p>
    <label for="concept-search">Search concepts</label><br>
    <input id="concept-search" type="search" autocomplete="off" placeholder="For example: 1.1.1, Guard Clauses, refactoring, or arrowhead">
    <table>
      <thead><tr><th>Catalog identifier</th><th>Concept</th><th>Classification</th><th>Category</th><th>Aliases</th></tr></thead>
      <tbody>
${rows}
      </tbody>
    </table>
  </main>
  <script>
    const search = document.querySelector('#concept-search');
    const rows = [...document.querySelectorAll('tbody tr')];
    search.addEventListener('input', () => {
      const query = search.value.trim().toLowerCase();
      rows.forEach((row) => { row.hidden = query !== '' && !row.dataset.search.includes(query); });
    });
  </script>
</body>
</html>`;
}

function updateExamples(records) {
  const byName = new Map(records.map((record) => [record.name, record]));
  const filenames = readdirSync(examplesDirectory).filter((filename) => filename.endsWith('.md')).sort();
  if (filenames.length !== records.length) fail(`Expected ${records.length} example files; found ${filenames.length}.`);
  const assigned = new Set();

  for (const filename of filenames) {
    const path = join(examplesDirectory, filename);
    let content = read(path);
    const title = content.match(/^# (.+)$/m)?.[1];
    const record = byName.get(title);
    if (!record) fail(`No canonical concept matches example ${filename} titled ${title ?? '<missing>'}.`);
    if (assigned.has(record.identifier)) fail(`Multiple example files map to ${record.identifier}.`);
    assigned.add(record.identifier);

    content = content.replace(/^\s*- \*\*Sources:\*\*.*\n/m, '');
    const identifierLine = `- **Catalog identifier:** ${record.identifier}`;
    if (/^\s*- \*\*Catalog identifier:\*\*.*$/m.test(content)) {
      content = content.replace(/^\s*- \*\*Catalog identifier:\*\*.*$/m, identifierLine);
    } else {
      const classificationLine = /^\s*- \*\*Classification:\*\*.*$/m;
      if (!classificationLine.test(content)) fail(`Missing classification metadata in ${filename}.`);
      content = content.replace(classificationLine, (line) => `${line}\n${identifierLine}`);
    }
    write(path, content);
  }

  if (assigned.size !== records.length) fail('Not every catalog concept has an example file.');
}

function migrate() {
  const legacy = read(catalogPath);
  if (!legacy.includes('**Classification:**')) fail('Migration expects the legacy catalog format with inline source citations.');
  const { catalog, records, sources } = parseLegacyCatalog(legacy);
  write(catalogPath, catalog);
  write(sourcesPath, sources);
  updateExamples(records);
  write(indexPath, renderIndex(records));
  check();
}

function buildIndex() {
  const records = parseCanonicalCatalog(read(catalogPath));
  write(indexPath, renderIndex(records));
  process.stdout.write(`Generated ${basename(indexPath)} for ${records.length} catalog concepts.\n`);
}

function check() {
  const records = parseCanonicalCatalog(read(catalogPath));
  const identifiers = new Set(records.map((record) => record.identifier));
  if (identifiers.size !== records.length) fail('Catalog identifiers are not unique.');
  const recordsByIdentifier = new Map(records.map((record) => [record.identifier, record]));
  const canonicalNames = new Set(records.map((record) => normalizedTerm(record.name)));
  if (canonicalNames.size !== records.length) fail('Canonical concept names are not unique.');
  const aliases = new Map();
  for (const record of records) {
    for (const alias of aliasTerms(record.aliases)) {
      const normalizedAlias = normalizedTerm(alias);
      if (canonicalNames.has(normalizedAlias) && normalizedAlias !== normalizedTerm(record.name)) {
        fail(`Alias ${alias} for ${record.identifier} duplicates another canonical concept name.`);
      }
      if (aliases.has(normalizedAlias) && aliases.get(normalizedAlias) !== record.identifier) {
        fail(`Alias ${alias} maps to multiple catalog identifiers.`);
      }
      aliases.set(normalizedAlias, record.identifier);
    }
  }
  if (read(catalogPath).match(/https?:\/\//)) fail('Canonical catalog contains an external URL.');

  if (!existsSync(sourcesPath)) fail('Source ledger is missing.');
  const sources = read(sourcesPath);
  const sourceHeaders = [...sources.matchAll(/^#### (\d+\.\d+\.\d+) (.+)$/gm)];
  const sourceRecords = sourceHeaders.map((header, index) => ({
    identifier: header[1],
    name: header[2],
    sourceText: sources.slice(header.index + header[0].length, index + 1 < sourceHeaders.length ? sourceHeaders[index + 1].index : sources.length),
  }));
  const sourceIdentifiers = new Set(sourceRecords.map((record) => record.identifier));
  if (sourceRecords.length !== records.length) fail(`Expected ${records.length} source records; found ${sourceRecords.length}.`);
  if (sourceIdentifiers.size !== records.length) fail(`Expected ${records.length} source records; found ${sourceIdentifiers.size}.`);
  for (const identifier of identifiers) {
    if (!sourceIdentifiers.has(identifier)) fail(`Missing source record for ${identifier}.`);
  }
  for (const record of sourceRecords) {
    const canonicalRecord = recordsByIdentifier.get(record.identifier);
    if (!canonicalRecord || record.name !== canonicalRecord.name) fail(`Source record ${record.identifier} does not match its canonical concept.`);
    if (markdownLinkCount(record.sourceText) === 0) fail(`Source record ${record.identifier} has no direct source URL.`);
  }

  const filenames = readdirSync(examplesDirectory).filter((filename) => filename.endsWith('.md'));
  if (filenames.length !== records.length) fail(`Expected ${records.length} example files; found ${filenames.length}.`);
  const exampleIdentifiers = new Set();
  for (const filename of filenames) {
    const content = read(join(examplesDirectory, filename));
    if (content.match(/^\s*- \*\*Sources:\*\*/m)) fail(`Example ${filename} retains a source metadata line.`);
    const match = content.match(/^\s*- \*\*Catalog identifier:\*\* (\d+\.\d+\.\d+)$/m);
    if (!match) fail(`Example ${filename} is missing a catalog identifier.`);
    if (!identifiers.has(match[1])) fail(`Example ${filename} uses unknown identifier ${match[1]}.`);
    if (exampleIdentifiers.has(match[1])) fail(`Multiple examples use identifier ${match[1]}.`);
    const title = content.match(/^# (.+)$/m)?.[1];
    if (title !== recordsByIdentifier.get(match[1]).name) fail(`Example ${filename} title does not match catalog identifier ${match[1]}.`);
    exampleIdentifiers.add(match[1]);
  }
  if (exampleIdentifiers.size !== records.length) fail('Not every catalog identifier has an example file.');

  if (!existsSync(indexPath)) fail('Generated HTML index is missing.');
  const index = read(indexPath);
  if (index.trimEnd() !== renderIndex(records).trimEnd()) fail('HTML index is stale; rebuild it from the canonical catalog.');
  const indexIdentifiers = new Set([...index.matchAll(/<td>(\d+\.\d+\.\d+)<\/td>/g)].map((match) => match[1]));
  if (indexIdentifiers.size !== records.length) fail(`Expected ${records.length} index rows; found ${indexIdentifiers.size}.`);
  for (const identifier of identifiers) {
    if (!indexIdentifiers.has(identifier)) fail(`Missing index row for ${identifier}.`);
  }

  process.stdout.write(`Validated ${records.length} catalog concepts, source records, index rows, and examples.\n`);
}

if (command === 'migrate') migrate();
if (command === 'index') buildIndex();
if (command === 'check') check();
