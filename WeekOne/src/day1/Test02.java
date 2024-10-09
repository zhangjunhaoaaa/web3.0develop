package day1;

import java.security.*;
import java.util.Base64;

public class Test02 {

    public static void main(String[] args) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        String nickname = "HoJuan"; // 请将此替换为您的昵称

        // 生成RSA公私钥对
        KeyPair keyPair = generateRSAKeyPair();

        // 生成满足POW条件的 nonce 和哈希
        String powResult = findHashWithLeadingZeros(nickname, 4); // 例如满足4个0开头的POW

        // 用私钥签名
        String signature = signWithPrivateKey(powResult, keyPair.getPrivate());

        // 用公钥验证签名
        boolean isVerified = verifyWithPublicKey(powResult, signature, keyPair.getPublic());

        System.out.println("Original Text: " + powResult);
        System.out.println("Signature: " + signature);
        System.out.println("Verification: " + isVerified);

        //Nonce: 10800
        //Hash: 000015b0f439d34eef33ebdf238bf97efe5f52fa681ea5b39789ea5df01ef649
        //Original Text: HoJuan10800
        //Signature: g//VKYHNyz80yLtqeEAVavY8ZElDBR8QdTYJoYofr2N/iuFfrZWlYgLd6gpZ+v92sbXfDJhSrytx/pICHjOMFCTh9uupfFZjvPBNxeeCBCb7J0a6Lasx0jPlBfBQHgLLmLvvtJBptFqM5qHpOx5/tGRmAj8306uWjIuvbAM8G/7ZuIK7mBkdOdyh8kf+kgbzyy8lbba2nLuwx8H+Xd6j339N5zoFIv1YPIPxWupSM2kGdJoqR1NQAHEif4sPoTKBXduyemtOvS9oMR3aSX7+eDCP+Ky8igli11Z14eVjHiePG9BjIjQje+YjFZJuHQSSVvkp4oQUIqJhAtHJ/417lQ==
        //Verification: true
    }

    // 生成RSA公私钥对
    public static KeyPair generateRSAKeyPair() throws NoSuchAlgorithmException {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(2048);
        return keyGen.generateKeyPair();
    }

    // 工作量证明（POW），找到符合条件的哈希
    public static String findHashWithLeadingZeros(String base, int numberOfZeros) throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        String target = "0".repeat(numberOfZeros);
        long nonce = 0;

        while (true) {
            String input = base + nonce;
            byte[] hashBytes = digest.digest(input.getBytes());
            String hash = bytesToHex(hashBytes);

            if (hash.startsWith(target)) {
                System.out.println("Nonce: " + nonce);
                System.out.println("Hash: " + hash);
                return input;
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

    // 使用私钥对数据进行签名
    public static String signWithPrivateKey(String data, PrivateKey privateKey) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(privateKey);
        signature.update(data.getBytes());
        byte[] signedBytes = signature.sign();
        return Base64.getEncoder().encodeToString(signedBytes);
    }

    // 使用公钥验证签名
    public static boolean verifyWithPublicKey(String data, String signature, PublicKey publicKey) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        Signature sig = Signature.getInstance("SHA256withRSA");
        sig.initVerify(publicKey);
        sig.update(data.getBytes());
        byte[] signatureBytes = Base64.getDecoder().decode(signature);
        return sig.verify(signatureBytes);
    }



}
