// src/components/ProtectedRoute.js
import React from 'react';
import { Route, Redirect } from 'react-router-dom';
import { useUser } from '@clerk/clerk-react';

const ProtectedRoute = ({ component: Component, ...rest }) => {
  const { isSignedIn } = useUser();

  return (
    <Route
      {...rest}
      render={(props) =>
        isSignedIn ? <Component {...props} /> : <Redirect to="/sign-in" />
      }
    />
  );
};

export default ProtectedRoute;
