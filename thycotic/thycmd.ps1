Param(
    [Alias('u')]
    [String] $user,
    [Alias('s')]
    [Int] $secretid,
    [Alias('l')]
    [Int] $launcherid,
    [Alias('m')]
    [String] $machine,
    [Alias('t')]
    [Switch] $use2fa
)

$secured_pass = Read-Host  -Prompt "Enter your password" -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secured_pass)
$pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

$site = "https://<fqdn>/SecretServer";
$api = "$site/api/v1";

Function Get-Token
{
    Param(
        [String] $user,
        [String] $pass,
        [Switch] $use2fa
    )

    $creds = @{
        username = $user
        password = $pass
        grant_type = "password"
    };

    $headers = $null
    If ($use2fa) {
        $headers = @{
            "OTP" = (Read-Host -Prompt "Enter your OTP for 2FA")
        }
    }

    $response = Invoke-RestMethod "$site/oauth2/token" -Method Post -Body $creds -Headers $headers;
    $token = $response.access_token;
    return $token;   
}

Function Launch-Secret
{
    Param(
        [Int] $secretid,
        [Int] $launcherid,
        [String] $prompt,
        [String] $token
    )

    $url = "$api/launchers/secret"

    $launch_with = @{
        secretid = $secretid
        launcherid = $launcherid
        promptFieldValue =$prompt
    };

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers.Add("Content-Type", "application/json")

    $json_launch_with = $launch_with | ConvertTo-Json

    $response = Invoke-RestMethod $url -Method Post -Body $json_launch_with -Headers $headers
    $ssUrl = $response.model.ssUrl
    return $ssUrl
}

$token = Get-Token -user $user -pass $pass -use2fa:$use2fa
$ssUrl = Launch-Secret -secretid $secretid -launcherid $launcherid -prompt $machine -token $token
$ssLink = "sslauncher:///$ssUrl"

& "C:\Program Files\Thycotic Software Ltd\Secret Server Protocol Handler\RDPWin.exe" $ssLink
