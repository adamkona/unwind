const puppeteer = require('puppeteer');

module.exports = {
    getScreenshot: getScreenshot,
};


async function getScreenshot(html) {
    const browser = await puppeteer.launch({
        'args': [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--single-process',
        ]
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 600, height: 100, deviceScaleFactor: 2 });
    await page.setContent(html, {waitUntil: 'networkidle0'});
    const image = await page.screenshot({ fullPage: true, encoding: 'binary' });
    await browser.close();
    return image;
}