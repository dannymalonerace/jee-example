import { test, expect } from '@playwright/test';

/**
 * Smoke-checks the site chrome: the home hero, the nav bar, and that the
 * (new) Contact page is reachable by clicking through the nav.
 */
test.describe('Site navigation', () => {
  test('home page renders the hero', async ({ page }) => {
    await page.goto('/hello/');
    await expect(page.getByRole('heading', { name: 'Hello, World' })).toBeVisible();
  });

  test('nav exposes the main sections', async ({ page }) => {
    await page.goto('/hello/');
    const nav = page.getByRole('navigation');
    await expect(nav.getByRole('link', { name: 'Greetings', exact: true })).toBeVisible();
    await expect(nav.getByRole('link', { name: 'About', exact: true })).toBeVisible();
    await expect(nav.getByRole('link', { name: 'Contact', exact: true })).toBeVisible();
  });

  test('can navigate to the Contact page from the nav', async ({ page }) => {
    await page.goto('/hello/');
    await page.getByRole('navigation')
      .getByRole('link', { name: 'Contact', exact: true })
      .click();

    await expect(page).toHaveURL(/\/hello\/contact$/);
    await expect(page.getByRole('heading', { name: 'Contact', level: 1 })).toBeVisible();
    await expect(page.getByRole('link', { name: 'hello@example.com' })).toBeVisible();
  });
});
