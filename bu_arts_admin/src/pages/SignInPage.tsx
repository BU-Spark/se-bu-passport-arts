// src/pages/SignInPage.js
import { SignIn } from '@clerk/clerk-react';

const SignInPage = () => (
  <div>
    <SignIn path="/sign-in" routing="path" />
  </div>
);

export default SignInPage;
