import { test, expect } from '@playwright/test';
import { HomePage } from '../pages/HomePage';
import { ContactPage } from '../pages/ContactPage';

/** Site chrome coverage via Page Objects (HomePage + NavBar + ContactPage). */
test.describe('Site navigation (POM)', () => {
  test('home page renders the hero', async ({ page }) => {
    const home = new HomePage(page);
    await home.goto();
    await expect(home.hero).toBeVisible();
  });

  test('nav exposes the main sections', async ({ page }) => {
    const home = new HomePage(page);
    await home.goto();
    await expect(home.nav.link('Greetings')).toBeVisible();
    await expect(home.nav.link('About')).toBeVisible();
    await expect(home.nav.link('Contact')).toBeVisible();
  });

  test('can navigate to the Contact page from the nav', async ({ page }) => {
    const home = new HomePage(page);
    await home.goto();
    await home.nav.goToContact();

    const contact = new ContactPage(page);
    await expect(page).toHaveURL(/\/hello\/contact$/);
    await expect(contact.heading).toBeVisible();
    await expect(contact.emailLink).toBeVisible();
  });
});
