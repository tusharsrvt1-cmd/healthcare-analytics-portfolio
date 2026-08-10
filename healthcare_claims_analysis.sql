-- ============================================================================
-- Healthcare Claims Analytics — Portfolio SQL Queries
-- Author: Tushar Srivastava
-- Database: healthcare_claims
-- Dataset: 1,500 claims | 300 members | 50 providers | 100 employees
--          (fictional/synthetic data — no real patient or PHI data)
-- Tools used across this project: Advanced Excel -> MySQL -> Power BI
-- ============================================================================


-- ============================================================================
-- SECTION 1: Data Quality Check
-- ============================================================================

-- Q1. How many claims are missing a payment date?
-- (Expected: every claim that is not yet Paid should have a NULL payment date)
SELECT COUNT(*) AS missing_payment_dates
FROM claims
WHERE Payment_Date IS NULL;


-- ============================================================================
-- SECTION 2: Claims Volume & Status Overview
-- ============================================================================

-- Q2. Total number of claims in the dataset
SELECT COUNT(*) AS total_claims
FROM claims;

-- Q3. Claim volume and % share by status
SELECT
    Claim_Status,
    COUNT(*) AS claim_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM claims) * 100, 2) AS pct_of_total
FROM claims
GROUP BY Claim_Status
ORDER BY claim_count DESC;


-- ============================================================================
-- SECTION 3: Processing Time Analysis
-- ============================================================================

-- Q4. Average claim processing time, overall
SELECT ROUND(AVG(Processing_Days), 2) AS avg_processing_days
FROM claims;

-- Q5. Average processing time by claim type
SELECT
    Claim_Type,
    ROUND(AVG(Processing_Days), 2) AS avg_processing_days
FROM claims
GROUP BY Claim_Type
ORDER BY avg_processing_days DESC;

-- Q6. [NEW] SLA turnaround buckets using CASE WHEN
-- Business question: how many claims are processed fast / on-target / slow?
SELECT
    CASE
        WHEN Processing_Days <= 3 THEN '0-3 days (Fast)'
        WHEN Processing_Days BETWEEN 4 AND 7 THEN '4-7 days (Standard)'
        ELSE '8+ days (Slow)'
    END AS sla_bucket,
    COUNT(*) AS claim_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM claims) * 100, 2) AS pct_of_total
FROM claims
GROUP BY sla_bucket
ORDER BY claim_count DESC;


-- ============================================================================
-- SECTION 4: Financial Overview
-- ============================================================================

-- Q7. Total billed amount across all claims
SELECT SUM(Billed_Amount) AS total_billed
FROM claims;

-- Q8. Claim volume, total billed, and average billed amount by claim type
SELECT
    Claim_Type,
    COUNT(*) AS total_claims,
    SUM(Billed_Amount) AS total_billed,
    ROUND(AVG(Billed_Amount), 2) AS avg_billed
FROM claims
GROUP BY Claim_Type
ORDER BY total_claims DESC;

-- Q9. Financial impact of denied claims
SELECT
    SUM(Billed_Amount) AS total_denied_billed,
    ROUND(AVG(Billed_Amount), 2) AS avg_denied_claim_amount
FROM claims
WHERE Claim_Status = 'Denied';

-- Q10. Paid-to-billed ratio, overall
SELECT
    SUM(Billed_Amount) AS total_billed,
    SUM(Paid_Amount) AS total_paid,
    ROUND(SUM(Paid_Amount) / SUM(Billed_Amount) * 100, 2) AS paid_to_billed_pct
FROM claims;

-- Q11. Paid-to-billed ratio by claim status
SELECT
    Claim_Status,
    SUM(Billed_Amount) AS total_billed,
    SUM(Paid_Amount) AS total_paid,
    ROUND(SUM(Paid_Amount) / SUM(Billed_Amount) * 100, 2) AS paid_to_billed_pct
FROM claims
GROUP BY Claim_Status;

-- Q12. Paid-to-billed ratio by claim type
SELECT
    Claim_Type,
    SUM(Billed_Amount) AS total_billed,
    SUM(Paid_Amount) AS total_paid,
    ROUND(SUM(Paid_Amount) / SUM(Billed_Amount) * 100, 2) AS paid_to_billed_pct
FROM claims
GROUP BY Claim_Type;


-- ============================================================================
-- SECTION 5: Regional Analysis
-- ============================================================================

-- Q13. Claim volume, billed/paid totals, and paid-to-billed ratio by region
SELECT
    Region,
    COUNT(*) AS total_claims,
    SUM(Billed_Amount) AS total_billed,
    SUM(Paid_Amount) AS total_paid,
    ROUND(SUM(Paid_Amount) / SUM(Billed_Amount) * 100, 2) AS paid_to_billed_pct
FROM claims
GROUP BY Region
ORDER BY total_billed DESC;

-- Q14. Regions with high claim volume (over 200 claims)
SELECT
    Region,
    COUNT(*) AS claim_count
FROM claims
GROUP BY Region
HAVING COUNT(*) > 200
ORDER BY claim_count DESC;


-- ============================================================================
-- SECTION 6: Provider Analysis (JOIN)
-- ============================================================================

-- Q15. Claim-level detail joined with provider name and specialty
SELECT
    c.Claim_ID,
    p.Provider_Name,
    p.Specialty,
    c.Billed_Amount
FROM claims c
JOIN providers p ON c.Provider_ID = p.Provider_ID;

-- Q16. Highest single billed claim, with the provider who submitted it
SELECT
    p.Provider_Name,
    p.Specialty,
    c.Billed_Amount
FROM claims c
JOIN providers p ON c.Provider_ID = p.Provider_ID
ORDER BY c.Billed_Amount DESC
LIMIT 1;

-- Q17. Total billed amount by provider specialty
SELECT
    p.Specialty,
    SUM(c.Billed_Amount) AS total_billed
FROM claims c
JOIN providers p ON c.Provider_ID = p.Provider_ID
GROUP BY p.Specialty
ORDER BY total_billed DESC;

-- Q18. [NEW] Window function — rank each provider by total billed amount
-- within their own specialty (top provider per specialty)
SELECT
    p.Specialty,
    p.Provider_Name,
    SUM(c.Billed_Amount) AS provider_total_billed,
    RANK() OVER (
        PARTITION BY p.Specialty
        ORDER BY SUM(c.Billed_Amount) DESC
    ) AS specialty_rank
FROM claims c
JOIN providers p ON c.Provider_ID = p.Provider_ID
GROUP BY p.Specialty, p.Provider_Name
ORDER BY p.Specialty, specialty_rank;


-- ============================================================================
-- SECTION 7: Member / Plan Analysis (JOIN)
-- ============================================================================

-- Q19. Total billed amount by plan type
SELECT
    m.Plan_Type,
    SUM(c.Billed_Amount) AS total_billed
FROM claims c
JOIN members m ON c.Member_ID = m.Member_ID
GROUP BY m.Plan_Type
ORDER BY total_billed DESC;

-- Q20. Claim volume and total billed amount by member state
SELECT
    m.State,
    COUNT(*) AS total_claims,
    SUM(c.Billed_Amount) AS total_billed
FROM claims c
JOIN members m ON c.Member_ID = m.Member_ID
GROUP BY m.State
ORDER BY total_billed DESC;

-- Q21. Paid-claims performance by plan type
SELECT
    m.Plan_Type,
    COUNT(*) AS paid_claims,
    SUM(c.Paid_Amount) AS total_paid,
    ROUND(AVG(c.Paid_Amount), 2) AS avg_paid_per_claim
FROM claims c
JOIN members m ON c.Member_ID = m.Member_ID
WHERE c.Claim_Status = 'Paid'
GROUP BY m.Plan_Type
ORDER BY total_paid DESC;


-- ============================================================================
-- SECTION 8: Combined Analysis (3-way JOIN)
-- ============================================================================

-- Q22. [NEW] Claims + members + providers together
-- Business question: which plan types have the most exposure to
-- out-of-network providers, and how much is billed as a result?
SELECT
    m.Plan_Type,
    p.Network_Status,
    COUNT(*) AS claim_count,
    SUM(c.Billed_Amount) AS total_billed
FROM claims c
JOIN members m ON c.Member_ID = m.Member_ID
JOIN providers p ON c.Provider_ID = p.Provider_ID
GROUP BY m.Plan_Type, p.Network_Status
ORDER BY m.Plan_Type, total_billed DESC;


-- ============================================================================
-- SECTION 9: Denial Analysis
-- ============================================================================

-- Q23. Denial reason breakdown — volume, % of all denials, billed amount,
-- and average processing time per reason
SELECT
    Denial_Reason,
    COUNT(*) AS denied_claims,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM claims WHERE Claim_Status = 'Denied') * 100, 2) AS pct_of_denials,
    SUM(Billed_Amount) AS billed_amount,
    ROUND(AVG(Processing_Days), 2) AS avg_processing_days
FROM claims
WHERE Claim_Status = 'Denied'
GROUP BY Denial_Reason
ORDER BY denied_claims DESC;


-- ============================================================================
-- SECTION 10: Modern SQL Pattern — CTE
-- ============================================================================

-- Q24. [NEW] Denial rate by claim type, rewritten using a CTE (WITH clause)
-- instead of nested nested subqueries — easier to read and to extend.
WITH claim_totals AS (
    SELECT
        Claim_Type,
        COUNT(*) AS total_claims
    FROM claims
    GROUP BY Claim_Type
),
denied_totals AS (
    SELECT
        Claim_Type,
        COUNT(*) AS denied_claims
    FROM claims
    WHERE Claim_Status = 'Denied'
    GROUP BY Claim_Type
)
SELECT
    t.Claim_Type,
    t.total_claims,
    COALESCE(d.denied_claims, 0) AS denied_claims,
    ROUND(COALESCE(d.denied_claims, 0) / t.total_claims * 100, 2) AS denial_rate_pct
FROM claim_totals t
LEFT JOIN denied_totals d ON t.Claim_Type = d.Claim_Type
ORDER BY denial_rate_pct DESC;
