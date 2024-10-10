package SyncBlockPrinciple;

import java.security.*;
import java.util.Base64;

public class RSAPowSignature {

    public static void main(String[] args) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        String nickname = "HoJuan"; // Please replace this with your nickname

        // Generate an RSA public-private key pair
        KeyPair keyPair = generateRSAKeyPair();

        // Generate a nonce and hash satisfying the Proof of Work (PoW) condition
        String powResult = findHashWithLeadingZeros(nickname, 4); // 例如满足4个0开头的POW

        // Sign with a private key
        String signature = signWithPrivateKey(powResult, keyPair.getPrivate());

        // Verify the signature with a public key
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

    // Generate an RSA public-private key pair
    public static KeyPair generateRSAKeyPair() throws NoSuchAlgorithmException {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(2048);
        return keyGen.generateKeyPair();
    }

    // Proof of Work (PoW), finding a hash that meets certain criteria
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

    // Convert a byte array to a hexadecimal string
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    // Sign data using a private key
    public static String signWithPrivateKey(String data, PrivateKey privateKey) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(privateKey);
        signature.update(data.getBytes());
        byte[] signedBytes = signature.sign();
        return Base64.getEncoder().encodeToString(signedBytes);
    }

    // Verify the signature using a public key
    public static boolean verifyWithPublicKey(String data, String signature, PublicKey publicKey) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
        Signature sig = Signature.getInstance("SHA256withRSA");
        sig.initVerify(publicKey);
        sig.update(data.getBytes());
        byte[] signatureBytes = Base64.getDecoder().decode(signature);
        return sig.verify(signatureBytes);
    }



}
