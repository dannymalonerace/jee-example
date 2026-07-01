import { type Page, type Locator } from '@playwright/test';

/**
 * Component object for the site header nav (rendered by layout/header.jspf).
 * Not a full page — a reusable piece shared across pages.
 */
export class NavBar {
  readonly root: Locator;

  constructor(private readonly page: Page) {
    this.root = page.getByRole('navigation');
  }

  /** A nav link by its visible text, e.g. link('Contact'). */
  link(name: string): Locator {
    return this.root.getByRole('link', { name, exact: true });
  }

  async goToContact(): Promise<void> {
    await this.link('Contact').click();
  }
}
