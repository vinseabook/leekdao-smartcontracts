const { merge } = require('sol-merger');

// Get the merged code as a string
async function mergeCode() {
  const mergedCode = await merge("./contracts/leekDao/SpaceCats.sol");
  console.log(mergedCode);
}


mergeCode()
