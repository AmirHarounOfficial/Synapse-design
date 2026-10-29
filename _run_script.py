import subprocess, sys
result = subprocess.run(
    [r"C:\Users\amirt\AppData\Roaming\ZadLoop\harness\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe",
     r"D:\work\Synapse Health App\generate_saudi_doc.py"],
    capture_output=True, text=True, timeout=120,
    cwd=r"D:\work\Synapse Health App"
)
print("STDOUT:", result.stdout)
print("STDERR:", result.stderr)
print("RC:", result.returncode)
