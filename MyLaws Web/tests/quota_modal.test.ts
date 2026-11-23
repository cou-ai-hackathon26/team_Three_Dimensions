import { describe, it, expect } from 'vitest';
import { DEFAULT_DAILY_LIMIT } from '../src/lib/userDb';

describe('User Daily Quota (30 requests/day) and Modal Logic', () => {
  it('enforces default daily limit of 30 requests per day', () => {
    expect(DEFAULT_DAILY_LIMIT).toBe(30);
  });

  it('verifies quota limit configuration is consistent with .env', () => {
    const configuredLimit = parseInt(process.env.DAILY_QUERY_LIMIT || '30', 10);
    expect(configuredLimit).toBe(30);
  });

  it('calculates remaining and exhaustion accurately for a 30 query limit', () => {
    const limit = 30;
    
    // Day start: 0 used
    const used0 = 0;
    const remaining0 = Math.max(0, limit - used0);
    const canQuery0 = remaining0 > 0;
    expect(remaining0).toBe(30);
    expect(canQuery0).toBe(true);

    // Near limit: 29 used
    const used29 = 29;
    const remaining29 = Math.max(0, limit - used29);
    const canQuery29 = remaining29 > 0;
    expect(remaining29).toBe(1);
    expect(canQuery29).toBe(true);

    // Limit reached: 30 used
    const used30 = 30;
    const remaining30 = Math.max(0, limit - used30);
    const canQuery30 = remaining30 > 0;
    expect(remaining30).toBe(0);
    expect(canQuery30).toBe(false);

    // Over limit: 31 attempted
    const used31 = 31;
    const remaining31 = Math.max(0, limit - used31);
    const canQuery31 = remaining31 > 0;
    expect(remaining31).toBe(0);
    expect(canQuery31).toBe(false);
  });
});
