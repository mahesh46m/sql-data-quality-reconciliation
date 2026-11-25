-- Synthetic loan-servicing ledger vs. bank statement. Demo schema only.
DROP TABLE IF EXISTS bank_transactions;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS loans;

CREATE TABLE loans (
    loan_id          INTEGER PRIMARY KEY,
    borrower_name    TEXT    NOT NULL,
    origination_date TEXT    NOT NULL,
    principal_amt    REAL    NOT NULL CHECK (principal_amt > 0),
    status           TEXT    NOT NULL CHECK (status IN ('ACTIVE','PAID_OFF','DEFAULT'))
);

-- Payments as recorded by the (fictional) servicing system.
CREATE TABLE payments (
    payment_id   INTEGER PRIMARY KEY,
    loan_id      INTEGER,            -- intentionally no FK so orphans can exist, as in real feeds
    payment_date TEXT    NOT NULL,
    amount       REAL,
    channel      TEXT,
    reference    TEXT
);

-- Cash actually received per the (fictional) bank statement.
CREATE TABLE bank_transactions (
    bank_txn_id  INTEGER PRIMARY KEY,
    reference    TEXT,
    posted_date  TEXT NOT NULL,
    amount       REAL NOT NULL
);

CREATE INDEX idx_payments_loan ON payments(loan_id);
CREATE INDEX idx_payments_ref  ON payments(reference);
CREATE INDEX idx_bank_ref      ON bank_transactions(reference);
