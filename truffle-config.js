const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {

  plugins: [
    'truffle-plugin-verify'
  ],

  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "999" // Match any network id
    },
    bsc_testnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://data-seed-prebsc-1-s1.binance.org:8545")
      },
      network_id: 97,
      gasPrice: 5000000000
    },
    bsc_mainnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://compassionate-lamport:scorch-whiny-riot-cherub-anchor-amused@nd-348-391-431.p2pify.com")
      },
      network_id: 56,
      gasPrice: 7000000000
    },
    ftm_testnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://rpc.testnet.fantom.network/")
      },
      network_id: 0xfa2,
      gasPrice: 20000000000
    },
    ftm: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://rpc.fantom.network")
      },
      network_id: 250,
      gasPrice: 3000000000
    },
    polygon_testnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://infallible-cray:guide-cabbie-encode-object-sweep-nutty@nd-860-518-111.p2pify.com")
      },
      network_id: 80001,
      gasPrice: 2000000000
    },
    polygon: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://flamboyant-kirch:stable-crept-patchy-maimed-pout-poncho@nd-789-715-066.p2pify.com")
      },
      network_id: 137,
      gasPrice: 2000000000
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  contracts_directory: './contracts/spacecats',
  contracts_build_directory: './build/',

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.0",
      docker: false,
      settings: {
        "remappings": [],
        "optimizer": {
          "enabled": false,
          "runs": 200
        },
        "evmVersion": "berlin",
        "libraries": {},
        "outputSelection": {
          "*": {
            "*": [
              "evm.bytecode",
              "evm.deployedBytecode",
              "abi"
            ]
          }
        }
      }
    }
  },

  api_keys: {
    ftmscan: 'JDIVS6EJ1HVMIX1N4J6YEVKFMFSY1EUYPD',
    polygonscan: 'G52PVA4REXYZPA44DSA6G8Z9VSICEM98J6',
    bscscan: '8AUQCRQ5EY951XRKAU27JQ4G3YETJ9AXYS'
  },

  db: {
    enabled: false
  }
};
