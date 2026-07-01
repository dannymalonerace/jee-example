import { type Page, type Locator } from '@playwright/test';

/** The new-greeting form (greeting-form.jsp) at /hello/greetings/new. */
export class GreetingFormPage {
  readonly nameInput: Locator;
  readonly messageInput: Locator;
  readonly saveButton: Locator;
  readonly nameError: Locator;

  constructor(private readonly page: Page) {
    this.nameInput = page.getByLabel('Name');
    this.messageInput = page.getByLabel('Message');
    this.saveButton = page.getByRole('button', { name: 'Save greeting' });
    this.nameError = page.locator('[data-field="name"]');
  }

  async goto(): Promise<void> {
    await this.page.goto('/hello/greetings/new');
  }

  async fillName(value: string): Promise<void> {
    await this.nameInput.fill(value);
  }

  async fillMessage(value: string): Promise<void> {
    await this.messageInput.fill(value);
  }

  async fill(name: string, message: string): Promise<void> {
    await this.fillName(name);
    await this.fillMessage(message);
  }

  async submit(): Promise<void> {
    await this.saveButton.click();
  }
}
