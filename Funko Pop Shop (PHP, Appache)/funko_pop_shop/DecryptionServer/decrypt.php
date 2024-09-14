<?php
function cryptoJsAesDecrypt($passphrase, $jsonString){
      // Debugging
      file_put_contents('debug.log', $jsonString . "\n", FILE_APPEND);
    
      $jsondata = json_decode($jsonString, true);
      
      // More debugging
      file_put_contents('debug.log', var_export($jsondata, true) . "\n", FILE_APPEND);
    try {
        $salt = hex2bin($jsondata["s"]);
        $iv  = hex2bin($jsondata["iv"]);
        $ct = base64_decode($jsondata["ct"]);
        $concatedPassphrase = $passphrase.$salt;
        $md5 = array();
        $md5[0] = md5($concatedPassphrase, true);
        $result = $md5[0];
        for ($i = 1; $i < 3; $i++) {
            $md5[$i] = md5($md5[$i - 1].$concatedPassphrase, true);
            $result .= $md5[$i];
        }
        $key = substr($result, 0, 32);
        $data = openssl_decrypt($ct, 'aes-256-cbc', $key, true, $iv);
        return $data;
    } catch (Exception $e) {
        return null;
    }
}
?>
