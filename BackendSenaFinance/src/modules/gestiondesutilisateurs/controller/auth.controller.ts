import { Request, Response } from "express";
import { User } from "../entity/user.entity";
import { JournalConnexion } from "../entity/journalConnexion";
import { sign, verify } from "jsonwebtoken";
import * as bcryptjs from "bcryptjs";
import { myDataSource } from "../../../configs/data-source";
import { generateServerErrorCode, success } from "../../../configs/response";
import { config } from "../../../configs/config";
import { ValidationError } from "class-validator";

export const Register = async (req: Request, res: Response) => {
    try {
        const { nom, email, password, prenom, telephone } = req.body;

        if (!email || !password || !nom) {
            return generateServerErrorCode(res, 400, '', 'Le nom, l\'email et le mot de passe sont requis.');
        }

        const userRepository = myDataSource.getRepository(User);

        const userExiste = await userRepository.findOne({ where: { email } });
        if (userExiste) {
            return generateServerErrorCode(res, 400, '', 'Cet utilisateur existe déjà');
        }

        if (telephone) {
            const telephoneExiste = await userRepository.findOne({ where: { telephone } });
            if (telephoneExiste) {
                return generateServerErrorCode(res, 400, '', 'Ce numéro de téléphone est déjà utilisé');
            }
        }

        const user = await userRepository.save({
            nom,
            prenom: prenom || null,
            telephone: telephone || `N/A-${Date.now()}`,
            email,
            password: await bcryptjs.hash(password, 12),
            typeCompte: 'utilisateur',
        });

        const { password: pwd, ...data } = user;
        return success(res, 201, data, "L'utilisateur a été enregistré avec succès");

    } catch (error: any) {
        if (error instanceof ValidationError) {
            return generateServerErrorCode(res, 400, error, 'Erreur de validation');
        }
        if (error.code === "ER_DUP_ENTRY" || error.code === "23505") {
            return generateServerErrorCode(res, 400, error, 'Cet utilisateur existe déjà');
        }
        return generateServerErrorCode(res, 500, '', "L'utilisateur n'a pas pu être enregistré. Réessayez plus tard.");
    }
};

export const Login = async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return generateServerErrorCode(res, 400, 'errors', "L'email et le mot de passe sont requis.");
        }

        const user = await myDataSource.getRepository(User).findOne({
            where: { email }
        });

        if (!user || !user.password || !(await bcryptjs.compare(password, user.password))) {
            return generateServerErrorCode(res, 400, 'Invalid Credentials', "Les informations d'identification sont invalides");
        }

        const { password: pwd, ...data } = user;

        const accessToken = sign(
            { userId: user.id, nom: user.nom, email: user.email },
            config.jwt.accessToken,
            { expiresIn: '8h' }
        );
        const refreshToken = sign(
            { userId: user.id },
            config.jwt.refreshToken,
            { expiresIn: '7d' }
        );

        // Journal de connexion
        const journal = new JournalConnexion();
        journal.entityId = user.id.toString();
        journal.userName = user.nom;
        journal.action = "Connexion";
        await myDataSource.getRepository(JournalConnexion).save(journal);

        return success(res, 200, { user: data, token: accessToken, refreshToken }, "L'authentification a réussi");

    } catch (error: any) {
        return generateServerErrorCode(res, 500, error, "Réessayez dans quelques instants.");
    }
};

export const LoginMobile = async (req: Request, res: Response) => {
    return Login(req, res);
};

export const ResetPasswordUser = async (req: Request, res: Response) => {
    try {
        const { newPassword, token } = req.body;

        if (!newPassword || !token) {
            return generateServerErrorCode(res, 400, '', 'Tous les champs obligatoires ne sont pas renseignés');
        }

        let decodedToken: any;
        try {
            decodedToken = verify(token, config.jwt.resetPasswordToken);
        } catch (error) {
            return generateServerErrorCode(res, 401, 'token invalide', "L'utilisateur n'est pas autorisé.");
        }

        const userRepository = myDataSource.getRepository(User);
        const userExiste = await userRepository.findOne({ where: { email: decodedToken.username } });

        if (!userExiste) {
            return generateServerErrorCode(res, 400, '', "Ce compte n'existe pas");
        }

        userRepository.merge(userExiste, {
            password: await bcryptjs.hash(newPassword, 12),
            firstConnectDate: new Date(),
        });

        await userRepository.save(userExiste);

        const { password, ...userWithoutPassword } = userExiste;
        return success(res, 200, userWithoutPassword, "Votre mot de passe a été modifié avec succès");

    } catch (error: any) {
        return generateServerErrorCode(res, 500, '', "Le mot de passe n'a pas pu être modifié.");
    }
};

export const SendResetPasswordCode = async (req: Request, res: Response) => {
    try {
        const { email } = req.body;

        if (!email) {
            return generateServerErrorCode(res, 400, 'errors', "L'email est requis.");
        }

        const user = await myDataSource.getRepository(User).findOne({ where: { email } });

        if (!user) {
            return generateServerErrorCode(res, 400, 'Invalid Credentials', "Ce compte n'existe pas");
        }

        const resetPasswordToken = sign(
            { username: user.email },
            config.jwt.resetPasswordToken,
            { expiresIn: '15m' }
        );

        const { password, ...data } = user;
        return success(res, 200, { user: data, resetPasswordToken }, "Le code de réinitialisation a été généré");

    } catch (error: any) {
        return generateServerErrorCode(res, 500, error, "Réessayez dans quelques instants.");
    }
};

export const verifyAuth = async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        const api_token = req.body['api_token'] || (authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null);

        if (!api_token) {
            return generateServerErrorCode(res, 400, 'session', "Jeton manquant");
        }

        const payload = verify(api_token, config.jwt.accessToken);
        if (!payload) {
            return res.status(401).send({ message: `Votre session a expiré, veuillez vous reconnecter` });
        }
        return res.status(200).send({ message: `Token valide` });
    } catch (err: any) {
        const message = err.name === 'TokenExpiredError'
            ? 'Votre session a expiré, veuillez vous reconnecter'
            : 'Le jeton est invalide';
        return generateServerErrorCode(res, 401, 'session', message);
    }
};

export const Refresh = async (req: Request, res: Response) => {
    try {
        const refreshToken = req.cookies?.['refreshToken'] || req.body?.refreshToken;

        if (!refreshToken) {
            return res.status(401).send({ message: 'unauthenticated' });
        }

        const payload: any = verify(refreshToken, config.jwt.refreshToken);
        if (!payload) {
            return res.status(401).send({ message: 'unauthenticated' });
        }

        const accessToken = sign(
            { userId: payload.userId, nom: payload.nom },
            config.jwt.accessToken,
            { expiresIn: '8h' }
        );

        res.cookie('accessToken', accessToken, {
            httpOnly: true,
            maxAge: 24 * 60 * 60 * 1000,
        });

        return res.status(200).send({ accessToken, message: 'success' });

    } catch (e: any) {
        return res.status(401).send({ message: 'unauthenticated' });
    }
};

export const Logout = async (req: Request, res: Response) => {
    try {
        const journal = new JournalConnexion();
        if (typeof req.query.userId === 'string') { journal.entityId = req.query.userId; }
        if (typeof req.query.userName === 'string') { journal.userName = req.query.userName; }
        journal.action = "Déconnexion";
        await myDataSource.getRepository(JournalConnexion).save(journal);

        res.cookie('accessToken', '', { maxAge: 0 });
        res.cookie('refreshToken', '', { maxAge: 0 });
        return res.status(200).json({ message: "Vous êtes déconnecté" });
    } catch (error: any) {
        return res.status(200).json({ message: "Vous êtes déconnecté" });
    }
};