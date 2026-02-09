// GitHub Action Script to replace content between markers in a file
const { readFile, writeFile } = require('node:fs/promises');

module.exports = async ({ content, filePath, beginMarker, endMarker }) => {
    // Validate required parameters
    if (!content?.trim()) throw new Error('Content is required');
    if (!filePath?.trim()) throw new Error('File path is required');
    if (!beginMarker?.trim() || !endMarker?.trim()) {
        throw new Error('Begin and end markers are required');
    }

    // Read current file content
    const fileContent = await readFile(filePath, 'utf8');

    // Find marker positions
    const beginIndex = fileContent.indexOf(beginMarker);
    const endIndex = fileContent.indexOf(endMarker);

    if (beginIndex === -1 || endIndex === -1) {
        throw new Error(`Markers not found in ${filePath}`);
    }

    // Construct new file content
    const beforeMarker = fileContent.slice(0, beginIndex + beginMarker.length);
    const afterMarker = fileContent.slice(endIndex);
    
    const wrapInCodeBlock = (text, lang = '') => {
        return '```' + lang + '\n' + text.trim() + '\n```';
    };
    
    const updatedContent = `${beforeMarker}\n${wrapInCodeBlock(content)}\n${afterMarker}`;

    // Write updated content back to file
    await writeFile(filePath, updatedContent, 'utf8');

    console.log(`${filePath} updated successfully`);
};
