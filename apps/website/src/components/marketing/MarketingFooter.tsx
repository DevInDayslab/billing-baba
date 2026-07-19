import { Link } from 'react-router-dom';

export function MarketingFooter() {
  return (
    <section className="footer">
      <div className="left">
        <div className="icon">
          <img src="/assets/BillingBabaLogo.png" alt="" className="h-14 w-auto object-cover" />
        </div>

        <p>
          Create Invoices, Purchases &amp; Quotations in less than 10 seconds. Share on WhatsApp with
          payment links and get paid
        </p>
      </div>
      <div className="mid">
        <h1 className="mb-4 font-semibold">Quick links</h1>
        <Link to="/features" className="hover:underline">
          Features
        </Link>
        <Link to="/pricing" className="hover:underline">
          Pricing
        </Link>
        <Link to="/download" className="hover:underline">
          Download
        </Link>
        <Link to="/contact" className="hover:underline">
          Contact Us
        </Link>
        <Link to="/privacy" className="hover:underline">
          Privacy
        </Link>
        <Link to="/terms" className="hover:underline">
          Terms
        </Link>
      </div>
      <div className="right">
        <h1>Address</h1>
        <p>Design Agency Head Office. Airport Road United Arab Emirate</p>
      </div>
    </section>
  );
}
