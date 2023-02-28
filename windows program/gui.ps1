Add-Type -AssemblyName System.Windows.Forms

# Check if the CHATGPT_TOKEN environment variable exists
$documentsPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents"
$filePath = "$documentsPath\api.txt"

if (Test-Path $filePath) {
    # File exists, read its contents
    $fileContents = Get-Content -Path $filePath
    $chatgpt_api = $fileContents 
} else {
    # File does not exist, create and write to it
    $api = Read-Host "What is your api?"
    $fileContents = $api
    New-Item -ItemType File -Path $filePath -Force | Out-Null
    Set-Content $filePath $fileContents
    $chatgpt_api = $fileContents 
}

# Get the dimensions of the primary monitor
$monitorSize = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
$monitorWidth = $monitorSize.Width
$monitorHeight = $monitorSize.Height

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ask a question"
$form.ClientSize = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

# Create a label for the question
$labelQuestion = New-Object System.Windows.Forms.Label
$labelQuestion.Text = "What is your question?"
$labelQuestion.AutoSize = $true
$labelQuestion.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($labelQuestion)

# Create a text box for the user's question
$textboxQuestion = New-Object System.Windows.Forms.TextBox
$textboxQuestion.Location = New-Object System.Drawing.Point(10, 30)
$textboxQuestion.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$textboxQuestion.AcceptsTab = $true
$textboxQuestion.WordWrap = $false
$textboxQuestion.Multiline = $true
$textboxQuestion.ScrollBars = "Vertical"
$textboxQuestion.Size = New-Object System.Drawing.Size(380, 40)
$form.Controls.Add($textboxQuestion)

# Create a button to generate an answer
$buttonAnswer = New-Object System.Windows.Forms.Button
$buttonAnswer.Text = "Answer"
$buttonAnswer.Location = New-Object System.Drawing.Point(10, 80) # Change the Y-coordinate to be below the first textbox
$buttonAnswer.Size = New-Object System.Drawing.Size(100, 23)
$buttonAnswer.Add_Click({
    $body = @{
        prompt = $textboxQuestion.Text
        model = "text-davinci-003"
        max_tokens = 4000
        temperature = 1.0
    }
    $headers = @{
        'Content-Type' = 'application/json'
        'Authorization' = "Bearer $chatgpt_api"
    }
    $jsonBody = $body | ConvertTo-Json
    $response = Invoke-WebRequest -Uri "https://api.openai.com/v1/completions" -Method POST -Body $jsonBody -Headers $headers -ContentType 'application/json'
$answer = $response.Content | ConvertFrom-Json | Select-Object -ExpandProperty choices | ForEach-Object { $_.text } 
$textboxAnswer.Text = $answer -replace '(?<=\S)\n', "`r`n" | Out-String

})
$form.Controls.Add($buttonAnswer)

# Create a button to clear the textboxes
$buttonClear = New-Object System.Windows.Forms.Button
$buttonClear.Text = "Clear"
$buttonClear.Location = New-Object System.Drawing.Point(120, 80) # Change the Y-coordinate to be below the first textbox
$buttonClear.Size = New-Object System.Drawing.Size(100, 23)
$buttonClear.Add_Click({
    $textboxQuestion.Text = ""
    $textboxAnswer.Text = ""
})
$form.Controls.Add($buttonClear)

# Create a label for the answer
$labelAnswer = New-Object System.Windows.Forms.Label
$labelAnswer.Text = "Answer:"
$labelAnswer.AutoSize = $true
$labelAnswer.Location = New-Object System.Drawing.Point(10, 90)
$form.Controls.Add($labelAnswer)

# Create a text box for the answer
$textboxAnswer = New-Object System.Windows.Forms.TextBox
$textboxAnswer.Location = New-Object System.Drawing.Point(10, 110)
$textboxAnswer.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$textboxAnswer.Width = $monitorWidth - 50
$textboxAnswer.Height = $monitorHeight - 150
$textboxAnswer.Size = New-Object System.Drawing.Size(380, 80)
$textboxAnswer.Multiline = $true
$textboxAnswer.ScrollBars = "Vertical"
$textboxAnswer.Anchor = 'Top,Bottom,Left,Right' 
$form.Controls.Add($textboxAnswer)

$form.ShowDialog() | Out-Null