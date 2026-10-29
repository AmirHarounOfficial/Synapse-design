$ErrorActionPreference = 'Stop'
$source = 'D:\work\Synapse Health App\pitch\arabic\SchooKeep_Pitch_Deck_Arabic_RTL_v2.pptx'
$preview = 'D:\work\Synapse Health App\pitch\.arabic-build\previews'
New-Item -ItemType Directory -Path $preview -Force | Out-Null
$app = New-Object -ComObject PowerPoint.Application
$deck = $null
try {
    $deck = $app.Presentations.Open($source, -1, 0, 0)
    foreach ($slide in $deck.Slides) {
        $slide.Export((Join-Path $preview ('Slide{0:00}.png' -f $slide.SlideIndex)), 'PNG', 1600, 900)
    }
    $deck.SaveAs('D:\work\Synapse Health App\pitch\arabic\SchooKeep_Pitch_Deck_Arabic_RTL_v2.pdf', 32)
    Write-Output ('Rendered {0} slides in PowerPoint' -f $deck.Slides.Count)
} finally {
    if ($deck) { $deck.Close() }
    $app.Quit()
}
