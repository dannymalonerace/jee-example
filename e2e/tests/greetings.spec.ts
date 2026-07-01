import { test, expect } from '@playwright/test';

/**
 * Exercises the core interactive feature: the greeting form's
 * POST-Redirect-GET happy path and its Bean Validation error path.
 */
test.describe('Greetings flow', () => {
  test('create a greeting and see it persist in the list', async ({ page }) => {
    const stamp = Date.now();
    const name = `Ada-${stamp}`;
    const message = `Hello from Playwright ${stamp}`;

    await page.goto('/hello/greetings/new');
    await page.getByLabel('Name').fill(name);
    await page.getByLabel('Message').fill(message);
    await page.getByRole('button', { name: 'Save greeting' }).click();

    // POST-Redirect-GET lands back on the list...
    await expect(page).toHaveURL(/\/hello\/greetings$/);
    // ...and the new row is rendered (proves WildFly -> JPA -> MySQL).
    await expect(page.getByRole('cell', { name })).toBeVisible();
    await expect(page.getByRole('cell', { name: message })).toBeVisible();
  });

  test('blank name shows a validation error and preserves the message', async ({ page }) => {
    const message = `preserve-me-${Date.now()}`;

    await page.goto('/hello/greetings/new');
    // Leave name blank; the form is `novalidate`, so the browser submits it
    // and the server returns 400 with the re-rendered form.
    await page.getByLabel('Message').fill(message);
    await page.getByRole('button', { name: 'Save greeting' }).click();

    await expect(page).toHaveURL(/\/hello\/greetings\/new$/);
    await expect(page.locator('[data-field="name"]')).toBeVisible();
    // Typed input is kept across the failed submit.
    await expect(page.getByLabel('Message')).toHaveValue(message);
  });
});
