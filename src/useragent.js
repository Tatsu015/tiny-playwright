const { chromium } = require("playwright-chromium");

(async () => {
    const browser = await chromium.launch({
        executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH,
    });
    const context = await browser.newContext();
    const page = await context.newPage();
    await page.goto('https://playwright.dev/');
    const h1 = await page.locator('h1').innerText();
    console.log('GET BY PLAYWRIGHT:', h1)
    await browser.close();
})();