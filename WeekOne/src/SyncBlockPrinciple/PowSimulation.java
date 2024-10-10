package SyncBlockPrinciple;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PowSimulation {

    public static void main(String[] args) throws NoSuchAlgorithmException {
        String nickname = "HoJuan"; // Please replace this with your nickname

        //The time calculated when it is 4
        long startTime = System.currentTimeMillis();
        findHashWithLeadingZeros(nickname, 4);
        long fourZerosTime = System.currentTimeMillis() - startTime;


        //The time calculated when it is 5
        startTime = System.currentTimeMillis();
        findHashWithLeadingZeros(nickname, 5);
        long fiveZerosTime = System.currentTimeMillis() - startTime;

        System.out.println("Time taken for 4 leading zeros: " + fourZerosTime + " ms");
        System.out.println("Time taken for 5 leading zeros: " + fiveZerosTime + " ms");

        //Nonce: 10800
        //Hash: 000015b0f439d34eef33ebdf238bf97efe5f52fa681ea5b39789ea5df01ef649
        //Nonce: 630383
        //Hash: 0000002c106a76e41a0ffc2bb423f7996fcba766572713138995805e71e5e6c7
        //Time taken for 4 leading zeros: 1242 ms
        //Time taken for 5 leading zeros: 3852 ms
    }



    public static void findHashWithLeadingZeros(String base, int numberOfZeros) throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        String target = "0".repeat(numberOfZeros);//Contains a specified number of leading zeros
        long nonce = 0;

        while (true) {
            String input = base + nonce;
            byte[] hashBytes = digest.digest(input.getBytes());//Calculate the SHA-256 hash of the input
            String hash = bytesToHex(hashBytes);

            if (hash.startsWith(target)) {
                System.out.println("Nonce: " + nonce);
                System.out.println("Hash: " + hash);
                break;
            }
            nonce++;
        }
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));//Convert the byte b into a two-digit hexadecimal string
        }
        return sb.toString();
    }


}
