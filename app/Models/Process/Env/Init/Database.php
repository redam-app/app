<?php

declare(strict_types=1);

namespace App\Models\Process\Env\Init;

use App\Exceptions\InvalidConfigurationException;
use App\Models\Process\Base;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Database extends Base
{
    public function execute(
        ?string $serverName,
        ?string $host,
        ?string $id,
        string $type,
        string $version,
        ?string $port,
        string $user,
        string $password,
        string $name
    ): void {
        $serverName = $this->getServerName(
            $serverName,
            $host
        );

        if ($this->variables->isEmpty($serverName)) {
            throw new InvalidConfigurationException('Invalid server name');
        }

        if ($this->variables->isEmpty($id)) {
            $id = sprintf(
                '%s_database',
                $serverName
            );
        }

        $this->config->set(
            $serverName,
            'database',
            $id
        );

        $this->config->set(
            $id,
            'type',
            $type
        );

        $this->config->set(
            $id,
            'version',
            $version
        );

        if (!$this->variables->isEmpty($port)) {
            $this->config->set(
                $id,
                'port',
                $port
            );
        }

        $this->config->set(
            $id,
            'user',
            $user
        );

        $this->config->set(
            $id,
            'password',
            $password
        );

        $this->config->set(
            $id,
            'name',
            $name
        );
    }
}
