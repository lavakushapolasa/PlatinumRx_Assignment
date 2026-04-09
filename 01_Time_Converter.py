minutes = int(input("Enter minutes: "))

hours = minutes // 60
mins = minutes % 60

if hours > 0:
    print(f"{hours} hr{'s' if hours > 1 else ''} {mins} minutes")
else:
    print(f"{mins} minutes")