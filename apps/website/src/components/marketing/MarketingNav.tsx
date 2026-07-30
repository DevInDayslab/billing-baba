import { Link } from 'react-router-dom';

export function MarketingNav() {
  return (
    <nav>
      <div className="flex-1">
        <Link to="/">
          <img
            src="/assets/BillingBabaLogo.png"
            alt="Billing Baba"
            className="h-16 w-auto object-cover"
          />
        </Link>
      </div>

      <div className="flex flex-1 justify-center item-center gap-4 font-semibold">
        <Link to="/features" className="hover:underline">
          Features
        </Link>
        <Link to="/download" className="hover:underline">
          Download
        </Link>
        <Link to="/pricing" className="hover:underline">
          Pricing
        </Link>
        <Link to="/contact" className="hover:underline">
          Contact
        </Link>
      </div>

      <div className="controls flex-1 flex justify-end">
        <Link to="/download">Sign In</Link>
        <Link className="signup" to="/download">
          Sign Up
        </Link>
      </div>
    </nav>
  );
}
