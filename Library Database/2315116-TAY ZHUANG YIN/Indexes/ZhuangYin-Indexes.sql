-- Index 1: Payment Trends Report (rpt_fine_payment_trends_method)
CREATE INDEX idx_payments_method_date ON Payments(paymentMethod, paymentDate);

-- Index 2: Unpaid Report (rpt_unpaid_fine_analytics)
CREATE INDEX idx_fines_status ON Fines(fineStatus);