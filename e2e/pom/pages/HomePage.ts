import { type Page, type Locator } from '@playwright/test';
import { NavBar } from './NavBar';

/** The home page (home.jsp) served at /hello/. */
export class HomePage {
  readonly nav: NavBar;
  readonly hero: Locator;

  constructor(private readonly page: Page) {
    this.nav = new NavBar(page);
    this.hero = page.getByRole('heading', { name: 'Hello, World' });
  }

  async goto(): Promise<void> {
    await this.page.goto('/hello/');
  }
}
