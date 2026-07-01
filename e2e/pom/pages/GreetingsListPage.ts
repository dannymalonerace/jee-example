import { type Page, type Locator } from '@playwright/test';

/** The greetings list (greetings-list.jsp) at /hello/greetings. */
export class GreetingsListPage {
  constructor(private readonly page: Page) {}

  async goto(): Promise<void> {
    await this.page.goto('/hello/greetings');
  }

  /** A table cell matching the given text (a name or message in the list). */
  cell(text: string): Locator {
    return this.page.getByRole('cell', { name: text });
  }
}
