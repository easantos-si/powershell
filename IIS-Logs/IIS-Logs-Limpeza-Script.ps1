<#
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$ @@@  @@@    @  @@@@  @  @ $$$$$$$
$$$$$$$ @    @   @  @  @     @ @  $$$$$$$
$$$$$$$ @@@  @@@    @  @     @@   $$$$$$$
$$$$$$$ @    @  @   @  @     @ @  $$$$$$$
$$$$$$$ @@@  @   @  @  @@@@  @  @ $$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*****************************************
* Ultima manutenção 27/08/2017          *
*****************************************
=========================================
= Versão 5.0                            =
=========================================
#>
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")
[System.Console]::WriteLine("Script Powershell para limpeza de arquivos de log do IIS");
[System.Console]::WriteLine("");
[System.String]::Format("Servidor: {0}",[System.Environment]::MachineName);
[System.Console]::WriteLine("");
[System.String]::Format("Inicio: {0}",[System.DateTime]::Now.ToString("dd/MM/yyyy hh:mm:ss.fffff"));
$QuantidadeDiasLimite = 15;
[System.Console]::WriteLine("");
[System.String]::Format("Data limite: {0}",[System.DateTime]::Now.AddDays($QuantidadeDiasLimite * (-1)))
[System.Console]::WriteLine("");
$iis = new-object Microsoft.Web.Administration.ServerManager 
$totalDeArquivosDeletados = 0;
$totalArquivosDeletadosEmMB = 0;
$totalArquivosMantidosEmMB = 0;
$totalDeArquivosMantidos = 0;
[System.Console]::WriteLine("");
foreach($site in $iis.Sites)
{
    [System.String]::Format("Site: {0}",$site.Name);

    if([System.IO.Directory]::Exists($site.LogFile.Directory))
    {           
        $diretorios = [System.IO.Directory]::GetDirectories([System.Environment]::ExpandEnvironmentVariables($site.LogFile.Directory));
    
        foreach($diretorio in $diretorios.GetEnumerator())
        {            
            $arquivos = [System.IO.Directory]::GetFiles($diretorio);

            [System.String]::Format("Diretório: {0}",$diretorio);

            foreach($arquivo in $arquivos)
            {
                if ([System.IO.Path]::GetExtension($arquivo).Equals(".log"))
                {
                    $arquivoLog = new-object System.IO.FileInfo($arquivo);
                              
                    if($arquivoLog.CreationTime -lt [System.DateTime]::Now.AddDays($QuantidadeDiasLimite * (-1)))
                    {
                        $arquivoLog.Delete();
                        [System.String]::Format("-> {1} | {2} | {3} | {0} - Deletado",$arquivoLog.Name,$arquivoLog.CreationTime.ToString("dd/MM/yyyy hh:mm:ss"),$arquivoLog.LastWriteTime.ToString("dd/MM/yyyy hh:mm:ss"),$arquivoLog.LastAccessTime.ToString("dd/MM/yyyy hh:mm:ss"));
                        $totalDeArquivosDeletados++;
                        $totalArquivosDeletadosEmMB += $arquivoLog.Length;
                    }
                    else
                        {
                            [System.String]::Format("-> {1} | {2} | {3} | {0} - Mantido",$arquivoLog.Name,$arquivoLog.CreationTime.ToString("dd/MM/yyyy hh:mm:ss"),$arquivoLog.LastWriteTime.ToString("dd/MM/yyyy hh:mm:ss"),$arquivoLog.LastAccessTime.ToString("dd/MM/yyyy hh:mm:ss"));
                            $totalDeArquivosMantidos++;
                            $totalArquivosMantidosEmMB += $arquivoLog.Length;
                        }
                }
            }
            [System.Console]::WriteLine("");
        }
    }
    else
        {
            [System.String]::Format("Diretório '{0}' não encontrado",$site.LogFile.Directory);
        }
}
if(!$totalArquivosDeletadosEmMB.Equals(0))
{
    $totalArquivosDeletadosEmMB = $totalArquivosDeletadosEmMB/1024/1024
}
if(!$totalArquivosMantidosEmMB.Equals(0))
{
    $totalArquivosMantidosEmMB = $totalArquivosMantidosEmMB/1024/1024
}
[System.Console]::WriteLine("");
[System.String]::Format("Fim: {0}",[System.DateTime]::Now.ToString("dd/MM/yyyy hh:mm:ss.fffff"));
[System.Console]::WriteLine("");
[System.String]::Format("Total de arquivos deletados: {0}",$totalDeArquivosDeletados);
[System.String]::Format("Total de espaço liberado pelos arquivos deletados: {0:n2} MB",$totalArquivosDeletadosEmMB);
[System.Console]::WriteLine("");
[System.String]::Format("Total de arquivos mantidos: {0}",$totalDeArquivosMantidos);
[System.String]::Format("Total de espaço ocupado pelos arquivos mantidos: {0:n2} MB",($totalArquivosMantidosEmMB));