# Diretório raiz onde estão as pastas com clipes mp4
$diretorioRaiz = "E:\Musicas-Mes-09"

# Verificar se o VLC está instalado
$vlcExe = "C:\Program Files\VideoLAN\VLC\vlc.exe"
if (!(Test-Path $vlcExe)) {
    Write-Host "VLC não encontrado. Verifique o caminho do VLC em `$vlcExe`."
    return
}

# Obter todas as subpastas no diretório raiz
$subpastas = Get-ChildItem -Path $diretorioRaiz -Directory

# Iterar sobre cada subpasta
foreach ($subpasta in $subpastas) {
    $pastaNome = $subpasta.Name
    $playlistNome = "$pastaNome.xspf"
    $caminhoPlaylist = Join-Path $subpasta.FullName $playlistNome

    # Obter arquivos .mp4 na subpasta atual
    $arquivosMP4 = Get-ChildItem -Path $subpasta.FullName -File -Filter "*.mp4"

    if ($arquivosMP4.Count -gt 0) {
        # Criar o conteúdo da lista de reprodução .xspf
        $playlistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">
    <title>Lista de reprodução para $pastaNome</title>
    <trackList>
"@

        # Adicionar cada arquivo .mp4 à lista de reprodução
        foreach ($arquivoMP4 in $arquivosMP4) {
            $playlistContent += @"
        <track>
            <location>file:///$($arquivoMP4.FullName -replace '\\', '/')</location>
            <title>$($arquivoMP4.Name)</title>
            <creator>$pastaNome</creator>
            <annotation></annotation>
            <duration></duration>
            <extension application="http://www.videolan.org/vlc/playlist/0">
                <vlc:id>$($arquivoMP4.Name.GetHashCode())</vlc:id>
            </extension>
        </track>
"@
        }

        # Fechar a lista de reprodução
        $playlistContent += @"
    </trackList>
</playlist>
"@

        # Salvar o conteúdo da lista de reprodução em um arquivo .xspf
        $playlistContent | Out-File -Encoding UTF8 -FilePath $caminhoPlaylist

        Write-Host "Playlist para $pastaNome criada: $caminhoPlaylist"
    } else {
        Write-Host "Nenhum arquivo .mp4 encontrado em $pastaNome."
    }
}

Write-Host "Processo concluído."
