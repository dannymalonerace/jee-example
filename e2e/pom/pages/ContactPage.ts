import { type Page, type Locator } from '@playwright/test';

/** The contact page (contact.jsp) at /hello/contact. */
export class ContactPage {
  readonly heading: Locator;
  readonly emailLink: Locator;

  constructor(private readonly page: Page) {
    this.heading = page.getByRole('heading', { name: 'Contact', level: 1 });
    this.emailLink = page.getByRole('link', { name: 'hello@example.com' });
  }

  async goto(): Promise<void> {
    await this.page.goto('/hello/contact');
  }
}
