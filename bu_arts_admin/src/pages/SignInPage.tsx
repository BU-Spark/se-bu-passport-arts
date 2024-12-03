// src/pages/SignInPage.js
import React from 'react';
import { SignIn } from '@clerk/clerk-react';

const SignInPage = () => (
  <div>
    <SignIn path="/sign-in" routing="path" />
  </div>
);

export default SignInPage;
