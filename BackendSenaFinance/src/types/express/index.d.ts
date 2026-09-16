import { User } from "../../modules/gestiondesutilisateurs/entity/user.entity";
declare global {
  namespace Express {
    interface Request {
      user?: User;
    }
  }
}
