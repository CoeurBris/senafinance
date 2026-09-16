export const config = {
  jwt: {
    accessToken: 'Sena@926',
    refreshToken: 'Estelle@926',
    resetPasswordToken:"Victoire@926",
    expiresIn: 10000,
  },
};


export const diffToTwoArray =(a1: string | any[], a2: string | any[]) =>{
  var a = [], diff = [];
  for (var i = 0; i < a1.length; i++) {
      a[a1[i]] = true;
  }
  for (var i = 0; i < a2.length; i++) {
      if (a[a2[i]]) {
          delete a[a2[i]];
      } else {
          a[a2[i]] = true;
      }
  }
  for (var k in a) {
      diff.push(k);
  }
  return diff;
}