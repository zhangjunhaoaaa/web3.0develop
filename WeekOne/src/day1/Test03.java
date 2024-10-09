package day1;

import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SignatureException;
import java.util.ArrayList;
import java.util.List;

public class Test03 {


    public static void main(String[] args) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        // Step 1: 工作量证明出块
        String nickname = "HoJuan"; // 请将此替换为您的昵称
        Block genesisBlock = createGenesisBlock(nickname);
        System.out.println("Genesis Block created with hash: " + genesisBlock.hash);

        // Step 2: 交易打包进入区块
        List<Transaction> transactions = new ArrayList<>();
        transactions.add(new Transaction("Alice", "Bob", 10));
        transactions.add(new Transaction("Bob", "Charlie", 5));
        Block newBlock = createNewBlock(genesisBlock, transactions, nickname);
        System.out.println("New Block created with hash: " + newBlock.hash);

        // Step 3: 节点同步区块
        List<Block> blockchain = new ArrayList<>();
        blockchain.add(genesisBlock);
        blockchain.add(newBlock);

        // 打印区块链信息
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

    // 创建创世区块
    public static Block createGenesisBlock(String nickname) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        return mineBlock(new Block(0, "0", null), nickname);
    }

    // 创建新块
    public static Block createNewBlock(Block previousBlock, List<Transaction> transactions, String nickname) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        Block newBlock = new Block(previousBlock.index + 1, previousBlock.hash, transactions);
        return mineBlock(newBlock, nickname);
    }

    // 工作量证明（挖矿）
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

    // 将字节数组转换为十六进制字符串
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    // 区块类
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

        // 计算交易的哈希值
        public String getTransactionsHash() {
            return transactions.stream()
                    .map(Transaction::toString)
                    .reduce("", (a, b) -> a + b);
        }
    }

    // 交易类
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
