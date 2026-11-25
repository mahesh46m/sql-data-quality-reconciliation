"""Generate deterministic synthetic data with known, injected data-quality issues."""
import random, sqlite3, sys
from datetime import date, timedelta

SEED = 42
random.seed(SEED)
db = sys.argv[1] if len(sys.argv) > 1 else "dq_demo.db"
con = sqlite3.connect(db)
con.executescript(open("sql/schema.sql").read())

start = date(2026, 1, 1)
loans = []
for i in range(1, 201):
    loans.append((i, f"Borrower {i:03d}", str(start - timedelta(days=random.randint(30, 900))),
                  round(random.uniform(50_000, 2_000_000), 2),
                  random.choices(["ACTIVE", "PAID_OFF", "DEFAULT"], [85, 10, 5])[0]))
con.executemany("INSERT INTO loans VALUES (?,?,?,?,?)", loans)

payments, bank = [], []
pid = bid = 0
for day in range(90):
    d = start + timedelta(days=day)
    for _ in range(random.randint(8, 14)):
        loan = random.choice(loans)
        amt = round(loan[3] * random.uniform(0.002, 0.01), 2)
        pid += 1; bid += 1
        ref = f"REF{pid:06d}"
        payments.append([pid, loan[0], str(d), amt, random.choice(["ACH", "WIRE", "CHECK"]), ref])
        bank.append([bid, ref, str(d + timedelta(days=random.choice([0, 0, 1]))), amt])

# ---- inject known issues (counts documented in README) ----
idx = list(range(len(payments)))
random.shuffle(idx)
inj = iter(idx)
for _ in range(6):                      # 6 duplicate payments (same loan/date/amount, new id+ref)
    p = payments[next(inj)]
    pid += 1
    payments.append([pid, p[1], p[2], p[3], p[4], f"REF{pid:06d}"])
for _ in range(8):                      # 8 payments missing from bank
    p = payments[next(inj)]
    bank[:] = [b for b in bank if b[1] != p[5]]
for _ in range(7):                      # 7 amount mismatches
    p = payments[next(inj)]
    for b in bank:
        if b[1] == p[5]:
            b[3] = round(b[3] + random.choice([-1, 1]) * random.uniform(5, 400), 2)
for _ in range(5):                      # 5 bank deposits with no payment record
    bid += 1
    bank.append([bid, f"UNK{bid:05d}", str(start + timedelta(days=random.randint(0, 89))),
                 round(random.uniform(1000, 9000), 2)])
for _ in range(5):                      # 5 orphan payments (loan_id not in loans)
    p = payments[next(inj)]
    p[1] = random.randint(900, 999)
for _ in range(3):                      # 3 payments with NULL or non-positive amount
    p = payments[next(inj)]
    p[3] = random.choice([None, 0, -250.0])
for _ in range(2):                      # 2 payments dated in the future
    p = payments[next(inj)]
    p[2] = "2027-06-01"
# one very large payment (threshold alert) and one volume spike day
pid += 1; bid += 1
payments.append([pid, 17, "2026-02-10", 1_450_000.00, "WIRE", f"REF{pid:06d}"])
bank.append([bid, f"REF{pid:06d}", "2026-02-10", 1_450_000.00])
for _ in range(60):
    pid += 1; bid += 1
    spike_amt = round(random.uniform(800, 2500), 2)
    payments.append([pid, random.randint(1, 200), "2026-03-05", spike_amt, "ACH", f"REF{pid:06d}"])
    bank.append([bid, f"REF{pid:06d}", "2026-03-05", spike_amt])

con.executemany("INSERT INTO payments VALUES (?,?,?,?,?,?)", payments)
con.executemany("INSERT INTO bank_transactions VALUES (?,?,?,?)", bank)
con.commit()
for t in ("loans", "payments", "bank_transactions"):
    print(t, con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0])
