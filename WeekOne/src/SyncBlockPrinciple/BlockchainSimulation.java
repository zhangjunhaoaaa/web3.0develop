package SyncBlockPrinciple;

import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SignatureException;
import java.util.ArrayList;
import java.util.List;

public class BlockchainSimulation {


    public static void main(String[] args) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        // Step 1: Proof-of-Work (PoW) block mining
        String nickname = "HoJuan"; // 请将此替换为您的昵称
        Block genesisBlock = createGenesisBlock(nickname);
        System.out.println("Genesis Block created with hash: " + genesisBlock.hash);

        // Step 2: Transactions are packaged into blocks
        List<Transaction> transactions = new ArrayList<>();
        transactions.add(new Transaction("Alice", "Bob", 10));
        transactions.add(new Transaction("Bob", "Charlie", 5));
        Block newBlock = createNewBlock(genesisBlock, transactions, nickname);
        System.out.println("New Block created with hash: " + newBlock.hash);

        // Step 3:Node synchronizes blocks
        List<Block> blockchain = new ArrayList<>();
        blockchain.add(genesisBlock);
        blockchain.add(newBlock);

        // Print blockchain information
        blockchain.forEach(block -> {
            System.out.println("Block Hash: " + block.hash);
            System.out.println("Previous Hash: " + block.previousHash);
            block.transactions.forEach(tx -> System.out.println(tx));
            System.out.println();
        });

        //Genesis Block created with hash: 00000d90b190c27311122317027a0643a952b518d61c65c063f250469470a3a9
        //New Block created with hash: 0000a3a913459a42788b439ec1284c56e814cf6314739850c7675f8914801da3
        //Block Hash: 00000d90b190c27311122317027a0643a952b518d61c65c063f250469470a3a9
        //Previous Hash: 0
        //
        //Block Hash: 0000a3a913459a42788b439ec1284c56e814cf6314739850c7675f8914801da3
        //Previous Hash: 00000d90b190c27311122317027a0643a952b518d61c65c063f250469470a3a9
        //Alice->Bob: 10
        //Bob->Charlie: 5


    }

    // Create a genesis block
    public static Block createGenesisBlock(String nickname) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        return mineBlock(new Block(0, "0", null), nickname);
    }

    // Create a new block
    public static Block createNewBlock(Block previousBlock, List<Transaction> transactions, String nickname) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        Block newBlock = new Block(previousBlock.index + 1, previousBlock.hash, transactions);
        return mineBlock(newBlock, nickname);
    }

    // Proof of Work (Mining)
    public static Block mineBlock(Block block, String nickname) throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        long nonce = 0;
        String target = "0000"; // 设定POW的难度为4个0开头的哈希

        while (true) {
            String input = block.index + block.previousHash + block.getTransactionsHash() + nonce + nickname;
            byte[] hashBytes = digest.digest(input.getBytes());
            String hash = bytesToHex(hashBytes);

            if (hash.startsWith(target)) {
                block.hash = hash;
                block.nonce = nonce;
                return block;
            }
            nonce++;
        }
    }

    // Convert a byte array to a hexadecimal string
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    // Block class
    static class Block {
        int index;
        String previousHash;
        List<Transaction> transactions;
        long nonce;
        String hash;

        public Block(int index, String previousHash, List<Transaction> transactions) {
            this.index = index;
            this.previousHash = previousHash;
            this.transactions = transactions != null ? transactions : new ArrayList<>();
        }

        // Calculate the hash of a transaction
        public String getTransactionsHash() {
            return transactions.stream()
                    .map(Transaction::toString)
                    .reduce("", (a, b) -> a + b);
        }
    }

    // Transaction class
    static class Transaction {
        String sender;
        String receiver;
        int amount;

        public Transaction(String sender, String receiver, int amount) {
            this.sender = sender;
            this.receiver = receiver;
            this.amount = amount;
        }

        @Override
        public String toString() {
            return sender + "->" + receiver + ": " + amount;
        }
    }


}
