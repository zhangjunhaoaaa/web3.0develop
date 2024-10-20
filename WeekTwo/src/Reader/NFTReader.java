//// 导入所需的Web3j库
//import org.web3j.protocol.Web3j;
//import org.web3j.protocol.http.HttpService;
//import org.web3j.protocol.core.methods.response.TransactionReceipt;
//import org.web3j.tx.Contract;
//import org.web3j.tx.gas.DefaultGasProvider;
//import org.web3j.abi.TypeReference;
//import org.web3j.abi.datatypes.Function;
//import org.web3j.abi.datatypes.Utf8String;
//import org.web3j.abi.datatypes.Address;
//import org.web3j.abi.datatypes.generated.Uint256;
//
//import java.util.Arrays;
//import java.util.List;
//
//// 定义NFTReader类，用于读取NFT信息
//public class NFTReader {
//
//    // Infura服务的URL，连接到以太坊主网
//    private static final String INFURA_URL = "https://mainnet.infura.io/v3/de59a8751dc74ff6be7b0bb97c0da664";
//    // NFT合约的地址
//    private static final String CONTRACT_ADDRESS = "0x0483b0dfc6c78062b9e999a82ffb795925381415";
//
//    // Web3j实例，用于与以太坊网络交互
//    private Web3j web3j;
//
//    // 构造函数，初始化Web3j实例
//    public NFTReader() {
//        web3j = Web3j.build(new HttpService(INFURA_URL));
//    }
//
//    // 获取NFT的所有者地址
//    public String getOwnerOf(Long tokenId) throws Exception {
//        // 构建ownerOf函数的调用
//        Function function = new Function(
//                "ownerOf",
//                Arrays.asList(new Uint256(tokenId)),
//                Arrays.asList(new TypeReference<Address>() {})
//        );
//
//        // 调用智能合约函数，并返回结果
//        String responseValue = callSmartContractFunction(function, CONTRACT_ADDRESS);
//        return responseValue;
//    }
//
//    // 获取NFT的元数据URI
//    public String getTokenURI(Long tokenId) throws Exception {
//        // 构建tokenURI函数的调用
//        Function function = new Function(
//                "tokenURI",
//                Arrays.asList(new Uint256(tokenId)),
//                Arrays.asList(new TypeReference<Utf8String>() {})
//        );
//
//        // 调用智能合约函数，并返回结果
//        String responseValue = callSmartContractFunction(function, CONTRACT_ADDRESS);
//        return responseValue;
//    }
//
//    // 调用智能合约函数并解码返回结果
//    private String callSmartContractFunction(Function function, String contractAddress) throws Exception {
//        // 编码函数调用
//        String encodedFunction = FunctionEncoder.encode(function);
//
//        // 发送以太坊调用请求
//        org.web3j.protocol.core.methods.response.EthCall response = web3j.ethCall(
//                        Transaction.createEthCallTransaction(null, contractAddress, encodedFunction),
//                        DefaultBlockParameterName.LATEST)
//                .send();
//
//        // 解码返回值
//        List<Type> output = FunctionReturnDecoder.decode(response.getValue(), function.getOutputParameters());
//        return output.get(0).getValue().toString();
//    }
//
//    // 主方法，入口点
//    public static void main(String[] args) throws Exception {
//        // 创建NFTReader实例
//        NFTReader nftReader = new NFTReader();
//        // 设置要查询的Token ID
//        Long tokenId = 1L;  // 替换成您要查询的 Token ID
//
//        // 获取所有者地址并打印
//        String owner = nftReader.getOwnerOf(tokenId);
//        System.out.println("Owner Address: " + owner);
//
//        // 获取元数据URI并打印
//        String tokenURI = nftReader.getTokenURI(tokenId);
//        System.out.println("Token URI: " + tokenURI);
//    }
//}
