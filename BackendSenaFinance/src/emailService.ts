// src/utils/emailService.ts
import nodemailer from 'nodemailer';
import dotenv from 'dotenv';
dotenv.config(); 

const transporter = nodemailer.createTransport({
  host: process.env.MAIL_HOST,
  port: Number(process.env.MAIL_PORT),
  secure: true, // Gmail nécessite un port sécurisé
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});

export const sendMail = async (
  to: string,
  subject: string,
  html: string
): Promise<void> => {
  // await transporter.sendMail({
  //   from: process.env.MAIL_FROM,
  //   to,
  //   subject,
  //   html,
  // });
  return ;
};
