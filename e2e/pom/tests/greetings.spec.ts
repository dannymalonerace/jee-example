import { test, expect } from '@playwright/test';
import { GreetingFormPage } from '../pages/GreetingFormPage';
import { GreetingsListPage } from '../pages/GreetingsListPage';

/**
 * Same coverage as the inline suite, expressed through Page Objects: the specs
 * describe intent ("fill", "submit") and the selectors live in the page classes.
 */
test.describe('Greetings flow (POM)', () => {
  test('create a greeting and see it persist in the list', async ({ page }) => {
    const stamp = Date.now();
    const name = `Ada-${stamp}`;
    const message = `Hello from Playwright ${stamp}`;

    const form = new GreetingFormPage(page);
    await form.goto();
    await form.fill(name, message);
    await form.submit();

    const list = new GreetingsListPage(page);
    await expect(page).toHaveURL(/\/hello\/greetings$/);
    await expect(list.cell(name)).toBeVisible();
    await expect(list.cell(message)).toBeVisible();
  });

  test('blank name shows a validation error and preserves the message', async ({ page }) => {
    const message = `preserve-me-${Date.now()}`;

    const form = new GreetingFormPage(page);
    await form.goto();
    // Leave name blank; the form is `novalidate`, so it submits and the server
    // returns 400 with the re-rendered form.
    await form.fillMessage(message);
    await form.submit();

    await expect(page).toHaveURL(/\/hello\/greetings\/new$/);
    await expect(form.nameError).toBeVisible();
    await expect(form.messageInput).toHaveValue(message);
  });
});
