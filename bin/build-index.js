//npm install yamljs
const YAML = require('yamljs');
const request = require('request');
const fs = require('fs');

const API_URL = "https://raw.githubusercontent.com/zalando/nakadi/master/api/nakadi-event-bus-api.yaml";
const OUTPUT_PATHS_FILE = "./docs/api-spec-extensions/paths/document-before-paths.md";
const OUTPUT_DEFINITION_FILE = "./docs/api-spec-extensions/definitions/document-before-definitions.md";
const HEADER_PATHS = '## Resources\n\n';

const HEADER_DEFINITIONS = "## Objects\n\n";

const cleanRegex = /[_\{\}\/]/g;
request(API_URL, (error, response, body) => {
    if (error) {
        throw Error("Can't download YAML");
    }

    // parse YAML string
    const swagger = YAML.parse(body);

    const paths = Object.keys(swagger.paths)
    .sort()
    .map(path =>
        Object.keys(swagger.paths[path]).map(
            method => `  - [${method.toUpperCase()} ${path}](#${method}-${path.replace(cleanRegex, '')})`
        )
    );

    const list = [].concat.apply([], paths).join('\n');

    let text = HEADER_PATHS + list;
    fs.writeFileSync(OUTPUT_PATHS_FILE, text, 'utf8');

    const definitions = Object.keys(swagger.definitions)
    .sort()
    .map(definition => `  - [${definition}](#${definition.toLowerCase()}})`);

    const definitionIndex = [].concat.apply([], definitions).join('\n');

    const definitionText = HEADER_DEFINITIONS + definitionIndex;
    fs.writeFileSync(OUTPUT_DEFINITION_FILE, definitionText, 'utf8');
});



